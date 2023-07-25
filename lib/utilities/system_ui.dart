import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class SystemUI {
  static void setDarkSystemUI(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarDividerColor: null,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarColor: Colors.black,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        )
    );
  }
}
