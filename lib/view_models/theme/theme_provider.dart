import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences? prefs;
  bool darkTheme = false;
  bool get dark => darkTheme;

  appProvider() {
    darkTheme = true;
    loadFromPrefs();
  }

  toggleTheme() {
    darkTheme = !darkTheme;
    saveToPrefs();
    notifyListeners();
  }

  initPrefs() async {
    prefs ??= await SharedPreferences.getInstance();
  }

  loadFromPrefs() async {
    await initPrefs();
    darkTheme = prefs!.getBool(key) ?? true;
    notifyListeners();
  }

  saveToPrefs() async {
    await initPrefs();
    prefs!.setBool(key, darkTheme);
    notifyListeners();
  }
}
