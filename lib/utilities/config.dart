import 'package:firebase_core/firebase_core.dart';

class Config {
  static Future<void> initFirebase() async {
    await Firebase.initializeApp();
  }
}
