import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class SystemUI {
  static SystemUiOverlayStyle setDarkSystemUI(BuildContext context) {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    );
  }
}
