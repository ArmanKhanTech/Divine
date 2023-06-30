import 'package:divine/utilities/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.initFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divine',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: (5)),
      vsync: this,
    );
  }

  void navigateUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Lottie.asset(
        'assets/lottie/splash_screen.json',
        controller: _controller,
        height: MediaQuery.of(context).size.height * 1,
        animate: true,
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..forward().whenComplete(() => navigateUser());
        },
      ),
    );
  }
}
