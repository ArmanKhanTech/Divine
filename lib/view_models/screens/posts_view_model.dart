import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_nude_detector/flutter_nude_detector.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart' as image_cropper;
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../posts/image_editor/image_editor_pro.dart';
import '../../posts/image_editor/utilities/utilities.dart';
import '../../profile/screens/pick_from_gallery_profile_picture.dart';
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

  TextEditingController locationTEC = TextEditingController();

  uploadProfilePicture(BuildContext context) async {
    if (media == null) {
      showSnackBar('Kindly select an image.', context, error: true);
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
        showSnackBar(e.toString(), context, error: true);
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
        await Navigator.push(context!, CupertinoPageRoute(builder: (_) => const PickFromGalleryProfilePicture()
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
      showSnackBar('Cancelled.', context, error: true);
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

  uploadPost(BuildContext context, {required List<File> images}) async {
    try {
      loading = true;
      notifyListeners();
      description ??= '';
      location ??= 'Unknown';
      hashtagsList ??= [];
      mentionsList ??= [];
      bool hasNudity = false;
      for(int i = 0; i < images.length; i++){
        final result = await FlutterNudeDetector.detect(path: images[i].path);
        if(result){
          hasNudity = true;

          break;
        }
      }
      if(hasNudity){
        showSnackBar('NSFW content detected.', context, error: true);
        loading = false;
        notifyListeners();
      } else{
        await postService.uploadPost(images, location!, description!, hashtagsList, mentionsList)
            .then((value) {
          if(hashtagsList.isNotEmpty) postService.addPostToHashtagsCollection(value, hashtagsList);
        });
        showSnackBar('Post uploaded successfully!', context, error: false);
        loading = false;
        notifyListeners();
      }
    } catch (e) {
      resetPost();
      loading = false;
      notifyListeners();
    }
  }

  uploadPostSingleImage({BuildContext? context, required XFile image}) async {
    try {
      Uint8List? bytes = await image.readAsBytes();
      bytes = await compressImage(bytes, 50);
      Navigator.push(
        context!,
        CupertinoPageRoute(
          builder: (context) => SingleImageEditor(
            image: bytes,
            multiImages: false,
            features: const ImageEditorFeatures(
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
    } catch (e) {
      showSnackBar(e.toString(), context, error: true);
    }
  }

  uploadPostMultipleImages({
    BuildContext? context,
    required List<XFile> images,
  }) async {
    try {
      List<Uint8List?> bytes = [];
      for(int i = 0; i < images.length; i++){
        bytes.add(await images[i].readAsBytes());
        bytes[i] = await compressImage(bytes[i]!, 50);
      }
      Navigator.push(
        context!,
        CupertinoPageRoute(
          builder: (context) => MultiImageEditor(
            images: bytes,
            features: const ImageEditorFeatures(
              crop: true,
              rotate: true,
              brush: false,
              emoji: true,
              filters: true,
              flip: true,
              text: true,
              blur: true,
            ),
            maxLength: 5,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(e.toString(), context, error: true);
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

  showSnackBar(String msg, context, {required bool error}) {
    showTopSnackBar(
      Overlay.of(context),
      error == false ? CustomSnackBar.success(
        message: msg,
      ) : CustomSnackBar.error(
        message: msg,
      ),
    );
  }
}