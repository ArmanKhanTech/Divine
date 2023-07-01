import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class is basically to toggle between dark & light theme & store its state in SharedPreferance.
class ThemeProvider extends ChangeNotifier {
  // This key is an unique identifier of the any value stored in SharedPreferance.
  final String key = "theme";
  SharedPreferences? _prefs;
  bool darkTheme = false;
  bool get dark => darkTheme;

  appProvider() {
    darkTheme = true;
    loadFromPrefs();
  }

  // Toggle between light & dark.
  toggleTheme() {
    darkTheme = !darkTheme;
    saveToPrefs();
    notifyListeners();
  }

  // Initialize the _prefs obejct.
  initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Get state of theme from SharedPreferance using key defined above.
  loadFromPrefs() async {
    await initPrefs();
    darkTheme = _prefs!.getBool(key) ?? true;
    notifyListeners();
  }

  // Store state of theme from SharedPreferance using key defined above.
  saveToPrefs() async {
    await initPrefs();
    _prefs!.setBool(key, darkTheme);
    notifyListeners();
  }
}
