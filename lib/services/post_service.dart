import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../utilities/firebase.dart';
import '../services/services.dart';

class PostService extends Service{
  // Generate random post id.
  String postId = const Uuid().v4();

  // Uploads the link of profile picture to the user's collection in FirestoreDB after uploading image to Firebase Storage.
  uploadProfilePicture(File image, User user) async {
    String link = await uploadImage(profilePic, image);
    var ref = usersRef.doc(user.uid);
    ref.update({
      "photoUrl": link,
    });
  }
}