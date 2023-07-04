import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../screens/profile_picture_screen.dart';
import '../../services/auth_service.dart';

// ViewModel of RegisterPage.
class RegisterViewModel extends ChangeNotifier {
  // Maintain state of child widgets.
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // bool flags.
  bool validate = false;
  bool loading = false;

  String? username, email, country, password, cPassword;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  FocusNode passFocusNode = FocusNode();
  FocusNode cPassFocusNode = FocusNode();

  AuthService auth = AuthService();

  // Register the user.
  register(BuildContext context) async {
    FormState form = formKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar(
          'Kindly fix all the errors before proceeding.', context);
    } else {
      if (password == cPassword) {
        loading = true;
        notifyListeners();
        try {
          bool success = await auth.createUser(
            name: username,
            email: email,
            password: password,
            country: country,
          );
          if (success) {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (_) => const ProfilePictureScreen(),
              ),
            );
          }
        } catch (e) {
          loading = false;
          notifyListeners();
          showInSnackBar(auth.handleFirebaseAuthError(e.toString()), context);
        }
        loading = false;
        notifyListeners();
      } else {
        showInSnackBar('The passwords do not match.', context);
      }
    }
  }

  // Setters for email, password, name, country and confirm password.
  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  setName(val) {
    username = val;
    notifyListeners();
  }

  setConfirmPass(val) {
    cPassword = val;
    notifyListeners();
  }

  setCountry(val) {
    country = val;
    notifyListeners();
  }

  // Show temporary text message on screen.
  void showInSnackBar(String msg, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}