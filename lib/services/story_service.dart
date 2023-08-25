import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/services/user_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/story_model.dart';
import '../utilities/firebase.dart';

class StoryService extends Service{
  String storyId = const Uuid().v1();

  UserService userService = UserService();

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