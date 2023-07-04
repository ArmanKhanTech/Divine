import 'package:divine/auth/login_page.dart';
import 'package:divine/utilities/system_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

// Welcome Screen of the app.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final Duration duration = const Duration(milliseconds: 1000);
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Colors.pink, Colors.blue],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    SystemUI.lightSystemUI();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        margin: const EdgeInsets.all(10),
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height / 10,
            ),
            SizedBox(
              width: size.width,
              height: size.height / 2,
              child: Lottie.asset("assets/lottie/welcome.json"),
            ),

            GradientText(
              'Welcome to Divine',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
              colors: const [
                Colors.blue,
                Colors.pink,
                Colors.purple
              ],
            ),

            const SizedBox(
              height: 5,
            ),

            GradientText(
              "Let the fun begin!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
              colors: const [
                Colors.blue,
                Colors.pink,
                Colors.purple
              ],
            ),

            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: SButton(
                  size: size,
                  color: Colors.blue,
                  text: "Get Started",
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),

            const SizedBox(
              height: 20,
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
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: ((context) => const LoginPage()),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(40),
        elevation: 5,
        child: Container(
          width: 200.0,
          height: 40.0,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(40)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: textStyle,
              ),
            ],
          ),
        )
      ),
    );
  }
}
