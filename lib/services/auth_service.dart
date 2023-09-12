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

  Future<bool> checkUsernameExists(String username) async {
    var res = await usersRef.where('username', isEqualTo: username).get();

    if (res.docs.isEmpty) {

      return false;
    } else {

      return true;
    }
  }

  Future<bool> createUser({String? email, String? password, String? username, String? country, User? user}) async {
    var res = await auth.createUserWithEmailAndPassword(
      email: '$email',
      password: '$password',
    );
    if (res.user != null) {
      await saveUserToFirestore(username!, res.user!, email!, country!);

      return true;
    } else {

      return false;
    }
  }

  saveUserToFirestore(String username, User user, String email, String country) async {
    await usersRef.doc(user.uid).set({
      'id': user.uid,
      'username': username,
      'email': email,
      'country': country,
      'photoUrl': user.photoURL ?? '',
      'name': '',
      'bio': '',
      'posts': 0,
      'postIds' : [],
      'postArchiveIds' : [],
      'mentions': 0,
      'mentionsIds': [],
      'createdAt': Timestamp.now(),
      'gender': '',
      'type': 'public',
      'saved': 0,
      'hashtags': {
        'nature' : 10,
        'food' : 10,
        'travel' : 10,
        'fashion' : 10,
        'music' : 10,
        'art' : 10,
        'sports' : 5,
        'technology' : 5,
        'health' : 5,
        'science' : 5,
        'religion' : 5,
        'culture' : 5,
      },
      'verified': false,
      'profession': '',
      'link': '',
    });
  }

  forgotPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  logOut() async {
    await auth.signOut();
  }

  Future<bool> checkUsername(String username) async {
    var res = await usersRef.where('username', isEqualTo: username).get();

    if (res.docs.isEmpty) {

      return true;
    } else {

      return false;
    }
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
          ' Log in again before retrying this request again.';
    } else {

      return e;
    }
  }

}
