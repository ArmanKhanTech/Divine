import 'package:divine/utilities/constants.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import '../components/pass_form_builder.dart';
import '../components/text_form_builder.dart';
import '../regex/regex.dart';
import '../utilities/system_ui.dart';
import '../view_models/auth/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Login screen of the app.
class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // ViewModel(backend basically) of LoginPage.
    LoginViewModel viewModel = Provider.of<LoginViewModel>(context);

    // Setup system UI.
    SystemUI.lightSystemUI();

    // UI of LoginPage.
    buildForm(BuildContext context, LoginViewModel viewModel) {
      return Form(
        key: viewModel.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(children: [
          TextFormBuilder(
            enabled: !viewModel.loading,
            prefix: CupertinoIcons.mail_solid,
            hintText: 'Email',
            textInputAction: TextInputAction.next,
            validateFunction: Regex.validateEmail,
            onSaved: (String value) {
              viewModel.setEmail(value);
            },
            focusNode: viewModel.emailFocusNode,
            nextFocusNode: viewModel.passwordFocusNode,
          ),
          const SizedBox(height: 10.0),
          PasswordFormBuilder(
            enabled: !viewModel.loading,
            prefix: Ionicons.lock_closed,
            suffix: Ionicons.eye_outline,
            hintText: "Password",
            textInputAction: TextInputAction.done,
            validateFunction: Regex.validatePassword,
            submitAction: () => viewModel.loginUser(context),
            obscureText: true,
            onSaved: (String val) {
              viewModel.setPassword(val);
            },
            focusNode: viewModel.passwordFocusNode,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 50.0),
              child: InkWell(
                onTap: () => viewModel.forgotPassword(context),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          SizedBox(
            height: 40.0,
            width: 200.0,
            child: FloatingActionButton(
              elevation: 1.0,
              backgroundColor: Constants.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => viewModel.loginUser(context),
            ),
          ),
        ]),
      );
    }

    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: viewModel.loading,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        key: viewModel.scaffoldKey,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 30),
            SizedBox(
              height: 400.0,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'assets/images/login_img.png',
              ),
            ),
            const Center(
              child: Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Login. Your fun awaits you!',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                  color: Constants.orange,
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            buildForm(context, viewModel),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account yet?',
                    style: TextStyle(fontSize: 15.0)),
                const SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign Up.',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Constants.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
