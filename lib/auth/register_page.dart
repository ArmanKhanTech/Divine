import 'package:divine/components/text_form_builder.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../components/pass_form_builder.dart';
import '../regex/regex.dart';
import '../utilities/system_ui.dart';
import '../view_models/auth/register_view_model.dart';

// Register Page of the app.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  @override
  Widget build(BuildContext context) {
    // ViewModel(backend basically) of RegisterPage.
    RegisterViewModel viewModel = Provider.of<RegisterViewModel>(context);

    // Setup system UI.
    SystemUI.lightSystemUI();

    // Registration Form.
    buildForm(RegisterViewModel viewModel, BuildContext context){
      return Form(
        key: viewModel.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormBuilder(
              enabled: !viewModel.loading,
              prefix: CupertinoIcons.person_2_fill,
              hintText: "Username",
              textInputAction: TextInputAction.next,
              validateFunction: Regex.validateName,
              onSaved: (String val) {
                viewModel.setName(val);
              },
              focusNode: viewModel.usernameFocusNode,
              nextFocusNode: viewModel.emailFocusNode,
              whichPage: "signup",
            ),
            const SizedBox(height: 10.0),
            TextFormBuilder(
              enabled: !viewModel.loading,
              prefix: CupertinoIcons.mail_solid,
              hintText: "Email",
              textInputAction: TextInputAction.next,
              validateFunction: Regex.validateEmail,
              onSaved: (String val) {
                viewModel.setEmail(val);
              },
              focusNode: viewModel.emailFocusNode,
              nextFocusNode: viewModel.countryFocusNode,
              whichPage: "signup",
            ),
            const SizedBox(height: 10.0),
            TextFormBuilder(
              enabled: !viewModel.loading,
              prefix: CupertinoIcons.globe,
              hintText: "Country",
              textInputAction: TextInputAction.next,
              validateFunction: Regex.validateCountry,
              onSaved: (String val) {
                viewModel.setCountry(val);
              },
              focusNode: viewModel.countryFocusNode,
              nextFocusNode: viewModel.passFocusNode,
              whichPage: "signup",
            ),
            const SizedBox(height: 10.0),
            PasswordFormBuilder(
              enabled: !viewModel.loading,
              prefix: Ionicons.lock_closed,
              suffix: Ionicons.eye_outline,
              hintText: "Password",
              textInputAction: TextInputAction.next,
              validateFunction: Regex.validatePassword,
              obscureText: true,
              onSaved: (String val) {
                viewModel.setPassword(val);
              },
              focusNode: viewModel.passFocusNode,
              nextFocusNode: viewModel.cPassFocusNode,
              whichPage: "signup",
            ),
            const SizedBox(height: 10.0),
            PasswordFormBuilder(
              enabled: !viewModel.loading,
              prefix: Ionicons.lock_open,
              suffix: Ionicons.eye_outline,
              hintText: "Confirm Password",
              textInputAction: TextInputAction.done,
              validateFunction: Regex.validatePassword,
              submitAction: () => viewModel.register(context),
              obscureText: true,
              onSaved: (String val) {
                viewModel.setConfirmPass(val);
              },
              focusNode: viewModel.cPassFocusNode,
              whichPage: "signup",
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              height: 40.0,
              width: 200.0,
              child: FloatingActionButton(
                elevation: 5.0,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Text(
                  'Signup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => viewModel.register(context),
              ),
            ),
          ],
        ),
      );
    }

    // UI of RegisterPage.
    return FlutterWebFrame(
      builder: (context) {
        return LoadingOverlay(
            isLoading: viewModel.loading,
            progressIndicator: circularProgress(context),
            child: Scaffold(
                key: viewModel.scaffoldKey,
                body: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height / 10,),
                    GradientText(
                      'Welcome to Divine.\nCreate a new account & connect with your friends.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                      ), colors: const [
                      Colors.blue,
                      Colors.purple,
                      Colors.pink,
                    ],
                    ),
                    const SizedBox(height: 20.0),
                    buildForm(viewModel, context),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            ' Log In.',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )
            ));
      },
      maximumSize: const Size(475.0, 812.0),
      enabled: kIsWeb,
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
}
