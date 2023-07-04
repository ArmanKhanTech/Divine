import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:divine/utilities/firebase.dart';

class AuthService {
  User getCurrentUser() {
    User user = auth.currentUser!;
    return user;
  }

  Future<bool> loginUser({String? email, String? password}) async {
    var res = await auth.signInWithEmailAndPassword(
      email: '$email',
      password: '$password',
    );

    if (res.user != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> createUser({String? email, String? password, String? name, String? country, User? user}) async {
    var res = await auth.createUserWithEmailAndPassword(
      email: '$email',
      password: '$password',
    );
    if (res.user != null) {
      await saveUserToFirestore(name!, res.user!, email!, country!);
      return true;
    } else {
      return false;
    }
  }

  saveUserToFirestore(String name, User user, String email, String country) async {
    await usersRef.doc(user.uid).set({
      'id': user.uid,
      'name': name,
      'email': email,
      'country': country,
      'photoUrl': user.photoURL ?? '',
      'bio': '',
      'followers': 0,
      'following': 0,
      'posts': 0,
      'favorites': 0,
      'createdAt': Timestamp.now(),
      'gender': '',
    });
  }

  forgotPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  logOut() async {
    await auth.signOut();
  }

  String handleFirebaseAuthError(String e) {
    if (e.contains("ERROR_WEAK_PASSWORD")) {
      return "Password is too weak.";
    } else if (e.contains("invalid-email")) {
      return "Invalid email.";
    } else if (e.contains("ERROR_EMAIL_ALREADY_IN_USE") ||
        e.contains('email-already-in-use')) {
      return "The email address is already in use by another account.";
    } else if (e.contains("ERROR_NETWORK_REQUEST_FAILED")) {
      return "Network error occurred!";
    } else if (e.contains("ERROR_USER_NOT_FOUND") ||
        e.contains('firebase_auth/user-not-found')) {
      return "Invalid credentials.";
    } else if (e.contains("ERROR_WRONG_PASSWORD") ||
        e.contains('wrong-password')) {
      return "Invalid credentials.";
    } else if (e.contains('firebase_auth/requires-recent-login')) {
      return 'This operation is sensitive and requires recent authentication.'
          ' Log in again before retrying this request.';
    } else {
      return e;
    }
  }

}
