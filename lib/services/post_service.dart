import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/models/user_model.dart';
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

  uploadSinglePost(File image, String location, String description, List<String> hashtagsList, List<String> mentionsList) async {
    String link = await uploadImage(posts, image);
    DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();
    UserModel user = UserModel.fromJson(
      doc.data() as Map<String, dynamic>,
    );
    var ref = postRef.doc();
    ref.set({
      "id": ref.id,
      "postId": ref.id,
      "username": user.username,
      "ownerId": auth.currentUser!.uid,
      "mediaUrl": link,
      "description": description,
      "location": location,
      "timestamp": Timestamp.now(),
      "likes": {},
      "hashtags": hashtagsList,
      "mentions": mentionsList,
    }).catchError((e) {
      // do something
    });
  }
}