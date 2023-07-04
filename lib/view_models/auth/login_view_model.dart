import 'package:divine/auth/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../regex/regex.dart';
import '../../services/auth_service.dart';

// ViewModel of LoginPage.
class LoginViewModel extends ChangeNotifier {
  // Maintain state of child widgets.
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // bool flags.
  bool validate = false;
  bool loading = false;

  String? email, password;

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  AuthService authService = AuthService();

  // Login the user.
  loginUser(BuildContext context) async {
    FormState form = formKey.currentState!;
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
              CupertinoPageRoute(builder: (_) => const LoginPage()));
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

  // Setters for email and password.
  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  // If user forgets the password.
  forgotPassword(BuildContext context) async {
    loading = true;
    notifyListeners();
    FormState form = formKey.currentState!;
    form.save();
    if (Regex.validateEmail(email) != null) {
      showSnackBar(
          'Please input a valid email to reset your password.', context);
    } else {
      try {
        await authService.forgotPassword(email!);
        showSnackBar(
            'Please check your email for instructions to reset your password.',
            context);
      } catch (e) {
        showSnackBar(e.toString(), context);
      }
    }
    loading = false;
    notifyListeners();
  }

  // Show temporary text message on screen.
  showSnackBar(String msg, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
