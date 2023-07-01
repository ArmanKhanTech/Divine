import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This class is basically to toggle between dark & light theme & store its state in SharedPreferance.
class ThemeProvider extends ChangeNotifier {
  // This key is an unique identifier of the any value stored in SharedPreferance.
  final String key = "theme";
  SharedPreferences? _prefs;
  bool _darkTheme = false;
  bool get dark => _darkTheme;

  appProvider() {
    _darkTheme = true;
    _loadFromPrefs();
  }

  // Toggle between light & dark.
  toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  // Initialize the _prefs obejct.
  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Get state of theme from SharedPreferance using key defined above.
  _loadFromPrefs() async {
    await _initPrefs();
    _darkTheme = _prefs!.getBool(key) ?? true;
    notifyListeners();
  }

  // Store state of theme from SharedPreferance using key defined above.
  _saveToPrefs() async {
    await _initPrefs();
    _prefs!.setBool(key, _darkTheme);
    notifyListeners();
  }
}
