import 'package:divine/services/user_service.dart';
import 'package:divine/utilities/config.dart';
import 'package:divine/utilities/constants.dart';
import 'package:divine/utilities/providers.dart';
import 'package:divine/view_models/theme/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth/login_page.dart';
import 'event_handlers/app_life_cycle_event_handler.dart';

void main() async {
  // Initiliaze the app depending on the platform.
  WidgetsFlutterBinding.ensureInitialized();
  await Config.initFirebase();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listening to app lifecyle event changes.
    WidgetsBinding.instance.addObserver(
      AppLifeCycleEventHandler(
        // The user exited the app.
        detachedCallBack: () => UserService().setUserStatus(false),
        // The user opened or reopened the app.
        resumeCallBack: () => UserService().setUserStatus(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Making use of MultiProvder to avoid writing boilerplate code.
    // https://pub.dev/documentation/provider/latest/provider/MultiProvider-class.html
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider themeProvider, Widget? child) {
          return MaterialApp(
            // Set app's name.
            title: Constants.appName,
            // Don't show the debug banner.
            debugShowCheckedModeBanner: false,
            // Set app's theme
            theme: themeData(
              themeProvider.dark ? Constants.darkTheme : Constants.lightTheme,
            ),
            // Check whether user is logged in or not, redirect to LoginPage if not, MainPage otherwise.
            // https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html
            home: const LoginPage(),
            /*StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  // Goto MainPage(user is logged in.)
                  return const LoginPage();
                } else {
                  // Goto LoginPage(user is not logged in.)
                  return const LoginPage();
                }
              }),
            ), */
          );
        },
      ),
    );
  }

  // https://fonts.google.com/specimen/Nunito+Sans
  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.nunitoSansTextTheme(
        theme.textTheme,
      ),
    );
  }
}
