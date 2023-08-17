import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/posts/screens/confirm_single_post_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_nude_detector/flutter_nude_detector.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart' as image_cropper;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../posts/image_editor/image_editor.dart';
import '../../posts/image_editor/utilities.dart';
import '../../posts/screens/pick_from_gallery_screen_posts.dart';
import '../../services/post_service.dart';
import '../../services/user_service.dart';
import '../../utilities/firebase.dart';

class PostsViewModel extends ChangeNotifier{
  UserService userService = UserService();
  PostService postService = PostService();

  GlobalKey<ScaffoldState> postScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> postFormKey = GlobalKey<FormState>();

  bool loading = false;
  bool edit = false;

  String? username, location, bio, description, email, commentData, ownerId, userId, type, imgLink, id, hashtags, mentions;

  List<String> hashtagsList = [];
  List<String> mentionsList = [];

  File? media;

  final picker = ImagePicker();

  Position? position;

  Placemark? placemark;

  File? userDp;

  TextEditingController locationTEC = TextEditingController();

  uploadProfilePicture(BuildContext context) async {
    if (media == null) {
      showSnackBar('Kindly select an image.', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        await postService.uploadProfilePicture(media!, auth.currentUser!);
        loading = false;
        DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();
        var users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        resetProfilePicture();
        Navigator.pop(context, users.photoUrl);
        notifyListeners();
      } catch (e) {
        loading = false;
        showSnackBar(e.toString(), context);
        notifyListeners();
      }
    }
  }

  pickProfileImage({bool camera = false, BuildContext? context}) async {
    loading = true;
    notifyListeners();
    try {
      XFile? pickedFile;
      if(camera == true){
        pickedFile = await picker.pickImage(
          source: camera ? ImageSource.camera : ImageSource.gallery,
          preferredCameraDevice: CameraDevice.front,
        );
      } else {
        await Navigator.push(context!, CupertinoPageRoute(builder: (_) => const PickFromGalleryScreenPosts()
        )).then((file) {
          pickedFile = file;
        });
      }
      image_cropper.CroppedFile? croppedFile = await image_cropper.ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        compressFormat: image_cropper.ImageCompressFormat.png,
        compressQuality: 25,
        aspectRatioPresets: [
          image_cropper.CropAspectRatioPreset.square,
          image_cropper.CropAspectRatioPreset.ratio3x2,
          image_cropper.CropAspectRatioPreset.original,
          image_cropper.CropAspectRatioPreset.ratio4x3,
          image_cropper.CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          image_cropper.AndroidUiSettings(
            toolbarTitle: 'Crop Profile Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: image_cropper.CropAspectRatioPreset.square,
            statusBarColor: Colors.black,
            backgroundColor: Colors.black,
            lockAspectRatio: false,
          ),
          image_cropper.IOSUiSettings(
            minimumAspectRatio: 1.0,
            title: 'Crop Profile Image',
          ),
          image_cropper.WebUiSettings(
            context: postScaffoldKey.currentContext!,
            presentStyle: image_cropper.CropperPresentStyle.dialog,
            enableZoom: true,
            enableResize: true,
            enableOrientation: true,
            boundary: const image_cropper.CroppieBoundary(
                height: 350
            ),
            viewPort: const image_cropper.CroppieViewPort(
                type: 'circle'
            ),
          ),
        ],
      );
      media = File(croppedFile!.path);
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showSnackBar('Cancelled.', context);
    }
  }

  resetProfilePicture() {
    media = null;
    notifyListeners();
  }

  resetPost() {
    media = null;
    description = null;
    location = null;
    hashtags = null;
    mentions = null;
    hashtagsList = [];
    mentionsList = [];
    edit = false;
    notifyListeners();
  }

  // TODO: Set initial values for editing post.
  setPost(PostModel post) {
    description = post.description;
    imgLink = post.mediaUrl;
    location = post.location;
    edit = true;
    notifyListeners();
  }

  getLocation() async {
    loading = true;
    notifyListeners();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await getLocation();
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);
      placemark = placemarks[0];
      location = "${placemarks[0].locality}, ${placemarks[0].country}";
      locationTEC.text = location!;
    }
    loading = false;
    notifyListeners();
  }

  uploadSinglePost(BuildContext context, File? image) async {
    try {
      loading = true;
      notifyListeners();
      if(image == null) showSnackBar('Kindly select an image.', context);
      description ??= '';
      location ??= 'Unknown';
      hashtagsList ??= [];
      mentionsList ??= [];
      final hasNudity = await FlutterNudeDetector.detect(path: image!.path);
      if(hasNudity){
        media!.delete();
        showSnackBar('NSFW Content Detected.', context);
        loading = false;
        notifyListeners();
      } else{
        await postService.uploadSinglePost(image, location!, description!, hashtagsList, mentionsList)
            .then((value) {
          if(hashtagsList.isNotEmpty) postService.addPostToHashtagsCollection(value, hashtagsList);
        });
        media!.delete();
        showSnackBar('Uploaded Successfully!', context);
        loading = false;
        notifyListeners();
      }
    } catch (e) {
      resetPost();
      loading = false;
      notifyListeners();
    }
  }

  uploadPostSingleImage({bool camera = false, BuildContext? context}) async {
    loading = true;
    notifyListeners();
    try {
      XFile? pickedFile;
      if(camera == true){
        pickedFile = await picker.pickImage(
          source: camera ? ImageSource.camera : ImageSource.gallery,
          preferredCameraDevice: CameraDevice.front,
        );
      } else {
        await Navigator.push(context!, CupertinoPageRoute(builder: (_) => const PickFromGalleryScreenPosts()
        )).then((file) {
          pickedFile = file;
        });
      }
      if(pickedFile != null){
        await Future.delayed(const Duration(milliseconds: 500), () async {
          Uint8List? bytes = await pickedFile?.readAsBytes();
          bytes = await compressImage(bytes!, 50);
          final editedImage = await Navigator.push(
            context!,
            CupertinoPageRoute(
              builder: (context) => SingleImageEditor(
                image: bytes,
                imagePath: pickedFile!.path,
                features: const ImageEditorFeatures(
                  captureFromCamera: true,
                  pickFromGallery: true,
                  crop: true,
                  rotate: true,
                  brush: false,
                  emoji: true,
                  filters: true,
                  flip: true,
                  text: true,
                  blur: true,
                ),
              ),
            ),
          );
          final convertedImage = await ImageUtils.convert(
            editedImage,
            format: 'png',
            quality: 75,
          );
          final tempDir = await getTemporaryDirectory();
          media = await File('${tempDir.path}/divine${DateTime.timestamp()}image.png').create();
          media?.writeAsBytesSync(convertedImage);
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => ConfirmSinglePostScreen(
                  postImage: media!,
                ),
              )
          );
        });
        loading = false;
        notifyListeners();
      } else {
        loading = false;
        notifyListeners();
      }
    } catch (e) {
      loading = false;
      notifyListeners();
    }
  }

  Future<Uint8List?> compressImage(Uint8List image, int quality) async {
    var result = await FlutterImageCompress.compressWithList(
      image,
      minWidth: 1080,
      minHeight: 720,
      quality: quality,
    );

    return result;
  }

  setDescription(String val) {
    description = val;
    notifyListeners();
  }

  setLocation(String val) {
    location = val;
    notifyListeners();
  }

  setHashtags(String val) {
    hashtags = val;
    hashtagsList = hashtags!.split(" ");
    notifyListeners();
  }

  setMentions(String val) {
    mentions = val;
    mentionsList = mentions!.split(" ");
    notifyListeners();
  }

  showSnackBar(String msg, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.white)), backgroundColor: Colors.blue,
        behavior: kIsWeb == true ? SnackBarBehavior.fixed : SnackBarBehavior.floating, duration: const Duration(seconds: 2), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: kIsWeb == true ? BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ) : BorderRadius.all(Radius.circular(30)),
        )
    ));
  }
}