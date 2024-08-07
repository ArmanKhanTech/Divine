import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../../components/pass_form_builder.dart';
import '../../../utilities/regex.dart';
import '../../../viewmodels/auth/register_view_model.dart';
import 'package:divine/components/text_form_builder.dart';
import 'package:divine/widgets/progress_indicator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    RegisterViewModel viewModel = Provider.of<RegisterViewModel>(context);

    Form buildForm(RegisterViewModel viewModel, BuildContext context) {
      return Form(
        key: viewModel.registerFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormBuilder(
              capitalization: false,
              enabled: !viewModel.loading,
              prefix: Ionicons.person,
              hintText: "Username",
              textInputAction: TextInputAction.next,
              validateFunction: Regex.validateUsername,
              onSaved: (String val) {
                viewModel.setUsername(val);
              },
              focusNode: viewModel.usernameFocusNode,
              nextFocusNode: viewModel.emailFocusNode,
              whichPage: "signup",
            ),
            const SizedBox(height: 20.0),
            TextFormBuilder(
              capitalization: false,
              enabled: !viewModel.loading,
              prefix: Ionicons.mail,
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
            const SizedBox(height: 20.0),
            TextFormBuilder(
              capitalization: true,
              enabled: !viewModel.loading,
              prefix: Ionicons.globe,
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
            const SizedBox(height: 20.0),
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
            const SizedBox(height: 20.0),
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
            const SizedBox(height: 10.0),
            const Text(
              textAlign: TextAlign.center,
              'By signing up you agree to our Terms of Use \n& Privacy Policy.',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              height: 45.0,
              width: MediaQuery.of(context).size.width * 0.9,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    'Signup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () => viewModel.register(context),
              ),
            ),
          ],
        ),
      );
    }

    return LoadingOverlay(
        isLoading: viewModel.loading,
        progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
        opacity: 0.5,
        color: Theme.of(context).colorScheme.surface,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(CupertinoIcons.chevron_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                iconSize: 30.0,
                color: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.only(bottom: 2.0),
              ),
            ),
            extendBodyBehindAppBar: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            key: viewModel.registerScaffoldKey,
            body: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 10),
                GradientText(
                  'Welcome to Divine.\nCreate a new account & \nconnect with your friends.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                  colors: const [
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
                        fontSize: 20.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        ' Log In.',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )));
  }
}
