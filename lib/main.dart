import 'package:divine/utilities/config.dart';
import 'package:divine/utilities/constants.dart';
import 'package:divine/utilities/providers.dart';
import 'package:divine/view_models/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.initFirebase();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: Consumer<ThemeProvider>(
          builder: (context, ThemeProvider themeProvider, Widget? child) {
            return MaterialApp(
              title: Constants.appName,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                brightness:
                    themeProvider.dark ? Brightness.dark : Brightness.light,
              ),
              home: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: ((BuildContext context, snapShot) {
                  if (snapShot.hasData) {
                    return const LoginPage();
                  } else {
                    return const LoginPage();
                  }
                }),
              ),
            );
          },
        ));
  }
}
