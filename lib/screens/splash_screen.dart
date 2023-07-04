import 'dart:async';
import 'package:divine/utilities/system_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../auth/register_page.dart';

// Splash Screen of the app.
class SplashScreen extends StatefulWidget{
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Colors.pink, Colors.blue],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    SystemUI.lightSystemUI();

    Timer(
        const Duration(seconds: 2),
            () => Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                    builder: (_) => StreamBuilder(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: ((BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          // Goto MainPage(user is logged in.)
                          return const RegisterPage();
                        } else {
                          // Goto LoginPage(user is not logged in.)
                          return const RegisterPage();
                        }
                      }),
                    ),)));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Center(
              child: Lottie.asset("assets/lottie/splash.json"),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/app_icon.png", width: 65, height: 65),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    color: Colors.blue,
                    height: 70,
                    width: 1,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GradientText(
                    'Divine',
                    style: const TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.w400,
                    ),
                    colors: const [
                      Colors.blue,
                      Colors.pink
                    ],
                  ),
                ],

              ),
            )

          ],
        ),
      ),
    );
  }
}