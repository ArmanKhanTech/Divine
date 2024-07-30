// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';

class EditProfileViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> editProfileScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> editProfileFormKey = GlobalKey<FormState>();

  bool validate = false;
  bool loading = false;

  UserService userService = UserService();

  final picker = ImagePicker();

  UserModel? user;

  File? image;

  String? country, username, name, bio, imgLink, profession, link, gender;

  Future<void> editProfile(BuildContext context) async {
    FormState form = editProfileFormKey.currentState!;
    form.save();
    if (profession == '') {
      profession = '';
    } else if (link == '') {
      link = '';
    } else if (gender == '') {
      gender = '';
    }

    notifyListeners();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showSnackBar('Kindly fix all the errors before submitting.', context,
          error: true);
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

  Future<void> updateProfileStatus(BuildContext context, String type) async {
    try {
      notifyListeners();
      bool success = await userService.updateProfileStatus(type: type);
      if (success) {
        showSnackBar('Your account is now $type.', context, error: false);
      }
    } catch (e) {
      notifyListeners();
    }
    notifyListeners();
  }

  void clear() {
    image = null;
    notifyListeners();
  }

  void setUser(UserModel val) {
    user = val;
    notifyListeners();
  }

  void setGender(String val) {
    gender = val;
    notifyListeners();
  }

  void setImage(UserModel user) {
    imgLink = user.photoUrl;
    notifyListeners();
  }

  void setName(String val) {
    name = val;
    notifyListeners();
  }

  void setCountry(String val) {
    country = val;
    notifyListeners();
  }

  void setBio(String val) {
    bio = val;
    notifyListeners();
  }

  void setUsername(String val) {
    username = val;
    notifyListeners();
  }

  void setProfession(String val) {
    profession = val;
    notifyListeners();
  }

  void setLink(String val) {
    link = val;
    notifyListeners();
  }

  void resetEditProfile() {
    image = username = bio = country = profession = link = name = null;
    notifyListeners();
  }

  void showSnackBar(String msg, context, {required bool error}) {
    showTopSnackBar(
      Overlay.of(context),
      error == false
          ? CustomSnackBar.success(
              message: msg,
            )
          : CustomSnackBar.error(
              message: msg,
            ),
    );
  }
}
