import 'package:divine/screens/splash_screen.dart';
import 'package:divine/secret_keys.dart';
import 'package:divine/services/user_service.dart';
import 'package:divine/utilities/constants.dart';
import 'package:divine/utilities/no_thumb_scrollbar.dart';
import 'package:divine/utilities/providers.dart';
import 'package:divine/view_models/theme/theme_view_model.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'event_handlers/app_life_cycle_event_handler.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase depending on the platform.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Firebase App Check.
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: webRecaptchaSiteKey,
    androidProvider: AndroidProvider.playIntegrity,
  );
  // Initialize Google Mobile Ads SDK.
  MobileAds.instance.initialize();
  // Set the orientation to portrait only.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  // Run the app.
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
    // Listening to app lifecycle event changes.
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
    // Making use of MultiProvider to avoid writing boilerplate code.
    // https://pub.dev/documentation/provider/latest/provider/MultiProvider-class.html
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeViewModel>(
        builder: (context, ThemeViewModel viewModel, Widget? child) {
          return MaterialApp(
            // Set app's name.
            title: Constants.appName,
            // Don't show the debug banner.
            debugShowCheckedModeBanner: false,
            // Set app's theme
            theme: themeData(
              viewModel.dark ? Constants.darkTheme : Constants.lightTheme,
            ),
            // Check whether user is logged in or not, redirect to LoginPage if not, MainPage otherwise.
            // https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html
            home: const SplashScreen(),
            // Disable scrollbars.
            scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
            builder: (context, child) {
              // Disable text scaling.
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
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
