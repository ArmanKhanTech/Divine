import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../utilities/firebase.dart';
import '../services/services.dart';

class PostService extends Service{
  String postId = const Uuid().v4();

  resetProfilePicture() async {
    DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();
    var user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    if (user.photoUrl != null) {
      await storage.refFromURL(user.photoUrl!).delete();
    }
  }

  uploadProfilePicture(File image, User user) async {
    await resetProfilePicture();
    String link = await uploadImage(profilePic, image);

    var ref = usersRef.doc(user.uid);

    ref.update({
      "photoUrl": link,
    });
  }

  Future<String> uploadSinglePost(File image, String location, String description, List<String> hashtagsList, List<String> mentionsList) async {
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
      "likes": {'count' : 0, 'userIds' : []},
      "hashtags": hashtagsList,
      "mentions": mentionsList,
    }).catchError((e) {});

    return ref.id;
  }

  addPostToHashtagsCollection(String postId, List<String> hashtagsList) async {
    for (String hashtag in hashtagsList) {
      await hashTagsRef.doc(hashtag).collection('posts').doc(postId).set({
        "postId": postId,
      });
      await hashTagsRef.doc(hashtag).update({
        "count": FieldValue.increment(1),
      });
    }
  }
}