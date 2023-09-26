import 'package:divine/auth/register_page.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../components/pass_form_builder.dart';
import '../components/text_form_builder.dart';
import '../utilities/regex.dart';
import '../view_models/auth/login_view_model.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LoginViewModel viewModel = Provider.of<LoginViewModel>(context);
    buildForm(BuildContext context, LoginViewModel viewModel) {
      return Form(
        key: viewModel.loginFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(children: [
          TextFormBuilder(
            capitalization: false,
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
            whichPage: "login",
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
            whichPage: "login",
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: InkWell(
                onTap: () => viewModel.forgotPassword(context),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          SizedBox(
            height: 40.0,
            width: 200.0,
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => viewModel.loginUser(context),
            ),
          ),
        ]),
      );
    }
    return FlutterWebFrame(
      builder: (context) {
        return LoadingOverlay(
          progressIndicator: circularProgress(context, const Color(0xFFFF9800)),
          opacity: 0.5,
          color: Theme.of(context).colorScheme.background,
          isLoading: viewModel.loading,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: AppBar(
                automaticallyImplyLeading: false,
              ),
            ),
            extendBodyBehindAppBar: true,
            backgroundColor: Theme.of(context).colorScheme.background,
            key: viewModel.loginScaffoldKey,
            body: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              children: [
                const SizedBox(
                  height: 20
                ),
                SizedBox(
                  height: kIsWeb == false ? MediaQuery.of(context).size.height * 0.45 : MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Lottie.asset(
                        'assets/lottie/login.json',
                        fit: BoxFit.fill
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20
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
                      color: Colors.orange,
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
                        style: TextStyle(fontSize: 18.0)),
                    const SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up.',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      enabled: kIsWeb,
      maximumSize: const Size(540.0, 960.0),
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}
