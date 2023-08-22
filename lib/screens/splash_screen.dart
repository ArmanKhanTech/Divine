import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../auth/login_page.dart';
import '../utilities/constants.dart';
import 'main_screen.dart';

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
    Timer(
        const Duration(seconds: 2),
            () => Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                    builder: (_) => StreamBuilder(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: ((BuildContext context, snapshot) {
                        if (snapshot.hasData) {

                          return const MainScreen();
                        } else {

                          return const LoginPage();
                        }
                      }),
                    ),)));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          systemOverlayStyle: Theme.of(context).colorScheme.background == Colors.white ? const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ) : const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
      ),
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
                  Image.asset("assets/images/app_icon.png", width: 60, height: 60),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    color: Colors.blue,
                    height: 65,
                    width: 1,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GradientText(
                    Constants.appName,
                    style: TextStyle(
                      fontSize: 55.0,
                      fontWeight: FontWeight.w500,
                      fontFamily: GoogleFonts.merriweather().fontFamily,
                    ),
                    colors: const [
                      Colors.blue,
                      Colors.pink,
                      Colors.purple
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