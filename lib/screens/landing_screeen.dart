import 'package:divine/auth/login_page.dart';
import 'package:divine/utilities/system_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    // Setup system UI.
    SystemUI.lightSystemUI();

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  height: 200.0,
                  width: 350.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Text(
              'Welcome to Divine',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
                child: Container(
                  height: 45.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(color: Colors.blue),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Colors.blue,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (_) => LoginPage(),
                    ),
                  );
                },
                child: Container(
                  height: 45.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(color: Colors.pink),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Colors.pink,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Register',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 20.0),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
