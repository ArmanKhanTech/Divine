import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/services/user_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/story_model.dart';
import '../utilities/firebase.dart';

class StoryService extends Service{
  String storyId = const Uuid().v1();

  UserService userService = UserService();

  showSnackBar(String msg, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),), backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        )));
  }

  sendStory(StoryModel story, String chatId) async {
    await storyRef
        .doc(chatId)
        .collection("stories")
        .doc(story.storyId)
        .set(story.toJson());
    await storyRef.doc(chatId).update({
      "userId": auth.currentUser!.uid,
    });
  }

  // TODO: add only followers to ids.
  Future<String> sendFirstStory(StoryModel story) async {
    List<String> ids = [];
    await usersRef.get().then((QuerySnapshot snapshot) {
      for (var documentSnapshot in snapshot.docs) {
        ids.add(documentSnapshot.get('id'));
      }
    });
    DocumentReference ref = await storyRef.add({
      'whoCanSee': ids,
    });
    await sendStory(story, ref.id);

    return ref.id;
  }

  Future<String> uploadImage(File image) async {
    Reference storageReference =
    storage.ref().child("story").child(uuid.v1()).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();

    return imageUrl;
  }
}