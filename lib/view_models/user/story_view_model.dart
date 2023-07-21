import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/story_model.dart';
import '../../services/post_service.dart';
import '../../services/story_service.dart';
import '../../services/user_service.dart';

class StoryViewModel extends ChangeNotifier {
  // Services.
  UserService userService = UserService();
  PostService postService = PostService();
  StoryService storyService = StoryService();

  // Keys.
  GlobalKey<ScaffoldState> storyScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> storyFormKey = GlobalKey<FormState>();

  // Flags.
  bool loading = true;
  bool edit = false;

  // Variables.
  String? username;
  String? description;
  String? email;
  String? userDp;
  String? userId;
  String? imgLink;
  String? id;
  int pageIndex = 0;

  // Objects.
  File? mediaUrl;

  sendStory(StoryModel story, String storyId) {
    storyService.sendStory(
      story,
      storyId,
    );
  }

  Future<String> sendFirstStory(StoryModel story) async {
    String newStoryId = await storyService.sendFirstStory(
      story,
    );

    return newStoryId;
  }

  // Reset Post.
  resetPost() {
    mediaUrl = null;
    description = null;
    edit = false;
    notifyListeners();
  }

  showSnackBar(String msg, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.white)), backgroundColor: Colors.purpleAccent,
        behavior: kIsWeb == true ? SnackBarBehavior.fixed : SnackBarBehavior.floating, duration: const Duration(seconds: 2), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: kIsWeb == true ? BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ) : BorderRadius.all(Radius.circular(30)),
        )));
  }
}