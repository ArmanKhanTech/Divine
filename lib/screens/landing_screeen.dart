import 'package:animate_do/animate_do.dart';
import 'package:divine/auth/login_page.dart';
import 'package:divine/utilities/system_ui.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Welcome Screen of the app.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final Duration duration = const Duration(milliseconds: 800);
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    SystemUI.lightSystemUI();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        margin: const EdgeInsets.all(8),
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 500),
              child: Container(
                margin: const EdgeInsets.only(
                  top: 50,
                  left: 5,
                  right: 5,
                ),
                width: size.width,
                height: size.height / 2,
                child: Lottie.asset("assets/lottie/welcome.json", fit: BoxFit.fitWidth),
              ),
            ),

            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 500),
              child: Text(
                "Welcome to Divine",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    fontFamily: "NunitoSans",
                    foreground: Paint()..shader = linearGradient),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 500),
              child: const Text(
                "Let your fun begin!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontFamily: "NunitoSans",
                    fontWeight: FontWeight.w300),
              ),
            ),

            ///
            Expanded(child: Container()),

            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 500),
              child: SButton(
                size: size,
                color: Colors.blue,
                text: "Login",
                textStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            ///
            const SizedBox(
              height: 20,
            ),

            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 800),
              child: SButton(
                size: size,
                color: Colors.pink,
                text: "Register",
                textStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            ///
            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}

class SButton extends StatelessWidget {
  const SButton({
    Key? key,
    required this.size,
    required this.color,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  final Size size;
  final Color color;
  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: ((context) => const LoginPage()),
          ),
        );
      },
      child: Container(
        width: size.width / 1.2,
        height: size.height / 15,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(40)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
