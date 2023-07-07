import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/post_service.dart';
import '../../services/user_service.dart';
import '../../utilities/constants.dart';
import '../../utilities/firebase.dart';


// Uploading Posts ViewModel.
class PostsViewModel extends ChangeNotifier{
  // Services.
  UserService userService = UserService();
  PostService postService = PostService();

  // Keys.
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Flags.
  bool loading = false;
  bool edit = false;

  // Variables.
  String? username, location, bio, description, email, commentData, ownerId, userId, type, imgLink, id;

  // Objects.
  File? mediaUrl;
  final picker = ImagePicker();
  Position? position;
  Placemark? placemark;
  File? userDp;

  // Upload profile picture to Firebase Storage & its link to user's collection.
  uploadProfilePicture(BuildContext context) async {
    if (mediaUrl == null) {
      showSnackBar('Kindly select an image.', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        await postService.uploadProfilePicture(
            mediaUrl!, auth.currentUser!);
        loading = false;
        Navigator.pop(context);
        notifyListeners();
      } catch (e) {
        loading = false;
        showSnackBar('Uploaded successfully!', context);
        notifyListeners();
      }
    }
  }

  // Profile ImagePicker function.
  pickProfileImage({bool camera = false, BuildContext? context}) async {
    loading = true;
    notifyListeners();
    try {
      XFile? pickedFile = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        preferredCameraDevice: CameraDevice.front,
      );
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        // Compression of image to 50% quality since it's a profile picture.
        compressFormat: ImageCompressFormat.png,
        compressQuality: 50,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Image',
            toolbarColor: Constants.lightAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            title: 'Crop Profile Image',
          ),
          WebUiSettings(
            context: scaffoldKey.currentContext!,
            presentStyle: CropperPresentStyle.dialog,
            enableZoom: true,
            enableResize: true,
            enableOrientation: true,
            boundary: const CroppieBoundary(
              height: 350
            ),
            viewPort: const CroppieViewPort(
              type: 'circle'
            ),
          ),
        ],
      );
      mediaUrl = File(croppedFile!.path);
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showSnackBar('Cancelled.', context);
    }
  }

  // Reset function executed on back button pressed.
  resetPost() {
    mediaUrl = null;
    description = null;
    location = null;
    edit = false;
    notifyListeners();
  }

  showSnackBar(String msg, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),), backgroundColor: Colors.pink,
        behavior: kIsWeb == true ? SnackBarBehavior.fixed : SnackBarBehavior.floating, duration: const Duration(seconds: 2), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: kIsWeb == true ? BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ) : BorderRadius.all(Radius.circular(30)),
        )));
  }
}