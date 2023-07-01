import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import '../utilities/system_ui.dart';
import '../view_models/auth/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static String hexColor = "#278aff";
  // Custom text colour.s
  Color color =
      Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);

  @override
  Widget build(BuildContext context) {
    // ViewModel(backend basically) of LoginPage.
    LoginViewModel viewModel = Provider.of<LoginViewModel>(context);

    // Setup system UI.
    SystemUI.lightSystemUI();

    // UI of LoginPage.
    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: viewModel.loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: viewModel.scaffoldKey,
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 20),
            SizedBox(
              height: 400.0,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'assets/images/login_img.jpg',
              ),
            ),
            const Center(
              child: Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Center(
              child: Text(
                'Login. Your fun awaits!',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            //buildForm(context, viewModel),
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
                        builder: (_) => LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign Up.',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: color,
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
