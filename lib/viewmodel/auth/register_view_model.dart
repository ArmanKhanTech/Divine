// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../screens/main_screen.dart';
import '../../service/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> registerScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  bool validate = false;
  bool loading = false;

  String? username, email, country, password, cPassword;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  FocusNode passFocusNode = FocusNode();
  FocusNode cPassFocusNode = FocusNode();

  AuthService auth = AuthService();

  Future<void> register(BuildContext context) async {
    FormState form = registerFormKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showSnackBar('Kindly fix all the errors before proceeding.', context);
    } else if (await auth.checkUsernameExists(username!)) {
      showSnackBar('Username already exists.', context);
    } else {
      if (password == cPassword) {
        loading = true;
        notifyListeners();

        try {
          bool success = await auth.createUser(
            username: username,
            email: email,
            password: password,
            country: country,
          );

          if (success) {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (_) => const MainScreen(),
              ),
            );
          }
        } catch (e) {
          loading = false;
          notifyListeners();
          showSnackBar(auth.handleFirebaseAuthError(e.toString()), context);
        }

        loading = false;
        notifyListeners();
      } else {
        showSnackBar('The passwords do not match.', context);
      }
    }
  }

  void setEmail(val) {
    email = val;
    notifyListeners();
  }

  void setPassword(val) {
    password = val;
    notifyListeners();
  }

  void setUsername(val) {
    username = val.toString().toLowerCase();
    notifyListeners();
  }

  void setConfirmPass(val) {
    cPassword = val;
    notifyListeners();
  }

  void setCountry(val) {
    country = val;
    notifyListeners();
  }

  void showSnackBar(String msg, context) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: msg,
      ),
    );
  }
}
