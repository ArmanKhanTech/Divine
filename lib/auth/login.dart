import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // This function is called when the login button is pressed.
  void _login() async {}

  @override
  Widget build(BuildContext context) {
    LoginViewModel viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _login,
          child: const Text('Login'),
        ),
      ),
    );
  }
}
