import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences? prefs;

  bool darkTheme = false;
  bool get dark => darkTheme;

  void appProvider() {
    darkTheme = true;
    loadFromPrefs();
  }

  void toggleTheme() {
    darkTheme = !darkTheme;
    saveToPrefs();
    notifyListeners();
  }

  Future<void> initPrefs() async {
    prefs ??= await SharedPreferences.getInstance();
  }

  void loadFromPrefs() async {
    await initPrefs();
    darkTheme = prefs!.getBool(key) ?? true;
    notifyListeners();
  }

  void saveToPrefs() async {
    await initPrefs();
    prefs!.setBool(key, darkTheme);
    notifyListeners();
  }
}
