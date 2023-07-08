import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/services/user_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/story_model.dart';
import '../utilities/firebase.dart';

class StatusService extends Service{
  String storyId = const Uuid().v1();
  UserService userService = UserService();

  // Show temporary text message on screen.
  showSnackBar(String msg, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15),), backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        )));
  }

  // Send Story to DB.
  sendStory(StoryModel story, String chatId) async {
    await statusRef
        .doc(chatId)
        .collection("statuses")
        .doc(story.storyId)
        .set(story.toJson());
    await statusRef.doc(chatId).update({
      "userId": auth.currentUser!.uid,
    });
  }

  // TODO: add only followers to ids.
  // Send first Story to DB.
  Future<String> sendFirstStory(StoryModel status) async {
    List<String> ids = [];
    await usersRef.get().then((QuerySnapshot snapshot) {
      for (var documentSnapshot in snapshot.docs) {
        ids.add(documentSnapshot.get('id'));
      }
    });
    DocumentReference ref = await statusRef.add({
      'whoCanSee': ids,
    });
    await sendStory(status, ref.id);
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