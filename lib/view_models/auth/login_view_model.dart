import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  // Maintain state of childs.
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool validate = false;
  bool loading = false;

  String? email, password;

  FocusNode emailFN = FocusNode();
  FocusNode passwordFN = FocusNode();

  AuthService authService = AuthService();

  // Login the user.
  loginUser(BuildContext context) async {
    FormState form = formKey.currentState!;
    form.save();

    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showSnackBar("Please fix all the errors before continuing", context);
    } else {
      loading = true;
      notifyListeners();
      try {
        bool confirm = await authService.loginUser(
          email: email,
          password: password,
        );
        if (confirm) {
          //Navigator.of(context).pushReplacement(newRoute)
        }
      } catch (e) {
        loading = false;
        notifyListeners();
        showSnackBar("...", context);
      }
    }
    loading = false;
    notifyListeners();
  }

  // If user forgets the password.
  forgotPassword(BuildContext conetext) async {
    //
  }

  // Show temporary text message on screen.
  showSnackBar(String msg, context) {}
}
