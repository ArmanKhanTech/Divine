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
    try {
      DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();
      var user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      if (user.photoUrl != null) {
        await storage.refFromURL(user.photoUrl!).delete();
      } else {

        return;
      }
    } catch (e) {

      return;
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

  Future<String> uploadPost(List<File> image, String location, String description, List<String> hashtagsList, List<String> mentionsList) async {
    List<String> postLink = [];

    for (File img in image) {
      String link = await uploadImage(posts, img);
      postLink.add(link);
    }

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
      "mediaUrl": postLink,
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

  uploadComment(String currentUserId, String comment, String postId,
      String ownerId, String mediaUrl) async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId).get();
    UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    await commentRef.doc(postId).collection("comments").add({
      "username": user.username,
      "comment": comment,
      "timestamp": Timestamp.now(),
      "userDp": user.photoUrl,
      "userId": user.id,
    });
    bool isNotMe = ownerId != currentUserId;
    if (isNotMe) {
      addCommentToNotification("comment", comment, user.username!, user.id!,
          postId, mediaUrl, ownerId, user.photoUrl!);
    }
  }

  addCommentToNotification(
      String type,
      String commentData,
      String username,
      String userId,
      String postId,
      String mediaUrl,
      String ownerId,
      String userDp) async {
    await notificationRef.doc(ownerId).collection('notifications').add({
      "type": type,
      "commentData": commentData,
      "username": username,
      "userId": userId,
      "userDp": userDp,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": Timestamp.now(),
    });
  }

  addLikesToNotification(String type, String username, String userId,
      String postId, String mediaUrl, String ownerId, String userDp) async {
    await notificationRef
        .doc(ownerId)
        .collection('notifications')
        .doc(postId)
        .set({
      "type": type,
      "username": username,
      "userId": auth.currentUser!.uid,
      "userDp": userDp,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": Timestamp.now(),
    });
  }

  removeLikeFromNotification(
      String ownerId, String postId, String currentUser) async {
    bool isNotMe = currentUser != ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUser).get();
      UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      notificationRef
          .doc(ownerId)
          .collection('notifications')
          .doc(postId)
          .get()
          .then((doc) => {
        if (doc.exists) {doc.reference.delete()}
      });
    }
  }
}