import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserViewModel extends ChangeNotifier {
  User? user;

  FirebaseAuth auth = FirebaseAuth.instance;

  void setUser() {
    user = auth.currentUser;
    notifyListeners();
  }
}
