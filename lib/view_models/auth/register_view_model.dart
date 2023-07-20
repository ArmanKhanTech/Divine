import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../screens/main_screen.dart';
import '../../services/auth_service.dart';

// ViewModel of RegisterPage.
class RegisterViewModel extends ChangeNotifier {
  // Maintain state of child widgets.
  GlobalKey<ScaffoldState> registerScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // bool flags.
  bool validate = false;
  bool loading = false;

  // Variables.
  String? username, email, country, password, cPassword;

  // FocusNodes.
  FocusNode usernameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  FocusNode passFocusNode = FocusNode();
  FocusNode cPassFocusNode = FocusNode();

  // Objects.
  AuthService auth = AuthService();

  // Register the user.
  register(BuildContext context) async {
    FormState form = registerFormKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showSnackBar(
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

  // Setters for email, password, name, country and confirm password.
  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  setUsername(val) {
    username = val.toString().toLowerCase();
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
  showSnackBar(String msg, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.white)), backgroundColor: Colors.blue,
        behavior: kIsWeb == true ? SnackBarBehavior.fixed : SnackBarBehavior.floating, duration: const Duration(seconds: 2), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: kIsWeb == true ? BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ) : BorderRadius.all(Radius.circular(30)),
        )));
  }
}