import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class EditProfileViewModel extends ChangeNotifier{
  // Keys.
  GlobalKey<ScaffoldState> editProfileScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> editProfileFormKey = GlobalKey<FormState>();

  // Flags.
  bool validate = false;
  bool loading = false;

  // Objects.
  UserService userService = UserService();
  final picker = ImagePicker();
  UserModel? user;
  File? image;

  // Variables.
  String? country, username, name, bio, imgLink, profession, link, gender;

  // Edit Profile function.
  editProfile(BuildContext context) async {
    FormState form = editProfileFormKey.currentState!;
    form.save();
    if (profession == '') {
      profession = '';
    } else if(link == '') {
      link = '';
    } else if(gender == ''){
      gender = '';
    }
    notifyListeners();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showSnackBar('Kindly fix all the errors before submitting.', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        bool success = await userService.updateProfile(
          image: image,
          username: username,
          name: name,
          bio: bio,
          country: country,
          link: link,
          profession: profession,
          gender: gender,
        );
        if (success) {
          clear();
          Navigator.pop(context);
        }
      } catch (e) {
        loading = false;
        notifyListeners();
      }
      loading = false;
      notifyListeners();
    }
  }

  updateProfileStatus(BuildContext context, String type) async {
    try {
      notifyListeners();
      bool success = await userService.updateProfileStatus(type: type);
      if (success) {
        showSnackBar('Your account is now $type.', context);
      }
    } catch (e) {
      notifyListeners();
    }
    notifyListeners();
  }

  clear() {
    image = null;
    notifyListeners();
  }

  // Setters.
  setUser(UserModel val) {
    user = val;
    notifyListeners();
  }

  setGender(String val){
    gender = val;
    notifyListeners();
  }

  setImage(UserModel user) {
    imgLink = user.photoUrl;
    notifyListeners();
  }

  setName(String val) {
    name = val;
    notifyListeners();
  }

  setCountry(String val) {
    country = val;
    notifyListeners();
  }

  setBio(String val) {
    bio = val;
    notifyListeners();
  }

  setUsername(String val) {
    username = val;
    notifyListeners();
  }

  setProfession(String val) {
    profession = val;
    notifyListeners();
  }

  setLink(String val) {
    link = val;
    notifyListeners();
  }

  resetEditProfile() {
    image = username = bio = country = profession = link = name = null;
    notifyListeners();
  }

  // Show temporary text message on screen.
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