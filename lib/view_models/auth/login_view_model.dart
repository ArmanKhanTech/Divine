import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../regex/regex.dart';
import '../../screens/main_screen.dart';
import '../../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> loginScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  bool validate = false;
  bool loading = false;

  String? email, password;

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  AuthService authService = AuthService();

  loginUser(BuildContext context) async {
    FormState form = loginFormKey.currentState!;
    form.save();

    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showSnackBar("Please fix all the errors before continuing.", context);
    } else {
      loading = true;
      notifyListeners();
      try {
        bool success = await authService.loginUser(
          email: email,
          password: password,
        );
        if (success) {
          Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (_) => const MainScreen()));
        }
      } catch (e) {
        loading = false;
        notifyListeners();
        showSnackBar(authService.handleFirebaseAuthError(e.toString()), context);
      }
    }
    loading = false;
    notifyListeners();
  }

  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  forgotPassword(BuildContext context) async {
    loading = true;
    notifyListeners();
    FormState form = loginFormKey.currentState!;
    form.save();
    if (Regex.validateEmail(email) != null) {
      showSnackBar(
          'Please input a valid email to reset your password.', context);
    } else {
      try {
        await authService.forgotPassword(email!);
        showSnackBar(
            'Please check your email for instructions to reset your password.',
            context
        );
      } catch (e) {
        showSnackBar(e.toString(), context);
      }
    }
    loading = false;
    notifyListeners();
  }

  showSnackBar(String msg, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.white)), backgroundColor: Colors.orange,
        behavior: kIsWeb == true ? SnackBarBehavior.fixed : SnackBarBehavior.floating, duration: const Duration(seconds: 2), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: kIsWeb == true ? BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ) : BorderRadius.all(Radius.circular(30)),
        )));
  }
}
