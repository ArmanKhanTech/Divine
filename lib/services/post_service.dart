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

      if(doc.exists) {
        var user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

        if (user.photoUrl != null) {
          await storage.refFromURL(user.photoUrl!).delete();
        } else {

          return;
        }
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

    if(doc.exists) {
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
        "hashtags": hashtagsList,
        "mentions": mentionsList,
        "type" : 'post'
      }).catchError((e) {});

      await addPostIdToUserCollection(ref.id);

      return ref.id;
    }

    return '';
  }

  addPostToHashtagsCollection(String postId, List<String> hashTags) async {
    for (String hashTag in hashTags) {
      DocumentSnapshot doc = await hashTagsRef.doc(hashTag).get();

      if (doc.exists) {
        await hashTagsRef.doc(hashTag).update({
          "count": FieldValue.increment(1),
          "posts": FieldValue.arrayUnion([postId]),
        });
      } else {
        await hashTagsRef.doc(hashTag).set({
          "count": 1,
          "posts": [postId],
        });
      }
    }
    await addOrIncrementHashtagsInUserCollection(hashTags);
  }

  addOrIncrementHashtagsInUserCollection(List<String> hashTags) async {
    for (String hashTag in hashTags) {
      DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();

      if (doc.exists) {

        await usersRef.doc(auth.currentUser!.uid).update({
          "hashtags.$hashTag": FieldValue.increment(1),
        });
      }
    }
  }

  decrementHashtagsInUserCollection(List<String> hashTags, int value) async {
    for (String hashTag in hashTags) {
      DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();

      if (doc.exists) {
        await usersRef.doc(auth.currentUser!.uid).update({
          "hashtags.$hashTag": FieldValue.increment(-value),
        });
      }
    }
  }

  addPostIdToUserCollection(String postId) async {
    DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();

    if(doc.exists) {
      UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

      if (user.postsIds!.isNotEmpty) {
        await usersRef.doc(auth.currentUser!.uid).update({
          "postsIds": FieldValue.arrayUnion([postId]),
        });
      } else {
        await usersRef.doc(auth.currentUser!.uid).update({
          "postsIds": [postId],
        });
      }
    }
  }

  incrementUserPostCount() async {
    var ref = usersRef.doc(auth.currentUser!.uid);

    ref.update({
      "posts": FieldValue.increment(1),
    });
  }

  decrementUserPostCount() async {
    var ref = usersRef.doc(auth.currentUser!.uid);

    ref.update({
      "posts": FieldValue.increment(-1),
    });
  }

  incrementMentionsCount(String userId) async {
    var ref = usersRef.doc(userId);

    ref.update({
      "mentionsCount": FieldValue.increment(1),
    });
  }

  decrementMentionsCount(String userId) async {
    var ref = usersRef.doc(userId);

    ref.update({
      "mentionsCount": FieldValue.increment(-1),
    });
  }

  /*uploadComment(String currentUserId, String comment, String postId,
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
  }*/

  getUserIdWithUserName(String username) async {
    QuerySnapshot snapshot = await usersRef.where('username', isEqualTo: username).get();

    if(snapshot.docs.isNotEmpty){

      return snapshot.docs.first.id;
    }

    return null;
  }

  addMentionToNotification(List<String> mentions, String postId) async {
    DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();

    if(doc.exists) {
      var user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

      for (String mention in mentions) {
        mention = mention.replaceAll("@", "");
        String userId = await getUserIdWithUserName(mention);

        DocumentSnapshot doc = await usersRef.doc(userId).get();

        if (doc.exists) {
          await notificationRef.doc(userId).collection('notifications').add({
            "type": "mention",
            "username": user.username,
            "userId": user.id,
            "profilePic": user.photoUrl,
            "postId": postId,
            "timestamp": Timestamp.now(),
          });
          await addMentionedPostIdToUserCollection(postId, userId);
        } else {

          continue;
        }
      }
    }
  }

  addMentionedPostIdToUserCollection(String postId, String userId) async {
    DocumentSnapshot doc = await usersRef.doc(userId).get();

    if (doc.exists) {
      var user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

      if(user.mentionsIds!.isNotEmpty) {
        await usersRef.doc(userId).update({
          "mentionsIds": FieldValue.arrayUnion([postId]),
        });
      } else {
        await usersRef.doc(userId).update({
          "mentionsIds": [postId],
        });
      }
    }
    await incrementMentionsCount(userId);
  }

  addCommentToNotification(
      String type,
      String commentData,
      String username,
      String userId,
      String postId,
      String ownerId,
      String profilePic) async {
    await notificationRef.doc(ownerId).collection('notifications').doc(postId).set({
      "type": type,
      "comment": commentData,
      "username": username,
      "userId": userId,
      "profilePic": profilePic,
      "postId": postId,
      "timestamp": Timestamp.now(),
    });
  }

  addLikesToNotification(String type, String username, String userId,
      String postId, String ownerId, String profilePic, List<dynamic> hashTags) async {
    await notificationRef.doc(ownerId).collection('notifications').doc(postId).set({
      "type": type,
      "username": username,
      "userId": auth.currentUser!.uid,
      "profilePic": profilePic,
      "postId": postId,
      "timestamp": Timestamp.now(),
    });
    if(hashTags.isNotEmpty){
      await addOrIncrementHashtagsInUserCollection(hashTags as List<String>);
    }
  }

  removeLikeFromNotification(String ownerId, String postId, String currentUser, List<dynamic> hashTags) async {
    bool isNotMe = currentUser != ownerId;

    if (isNotMe) {
      notificationRef.doc(ownerId).collection('notifications').doc(postId).get().then((doc) async {
            if (doc.exists) {
              doc.reference.delete();
            }

            await decrementHashtagsInUserCollection(hashTags as List<String>, 1);
      });
    }
  }
}