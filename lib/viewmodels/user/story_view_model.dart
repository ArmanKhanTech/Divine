import 'dart:io';

import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/story_model.dart';
import '../../services/post_service.dart';
import '../../services/story_service.dart';
import '../../services/user_service.dart';

class StoryViewModel extends ChangeNotifier {
  UserService userService = UserService();
  PostService postService = PostService();
  StoryService storyService = StoryService();

  GlobalKey<ScaffoldState> storyScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> storyFormKey = GlobalKey<FormState>();

  bool loading = true;
  bool edit = false;

  String? username;
  String? description;
  String? email;
  String? userDp;
  String? userId;
  String? imgLink;
  String? id;

  int pageIndex = 0;

  File? mediaUrl;

  Future<void> sendStory(StoryModel story, String storyId) async {
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

  void resetPost() {
    mediaUrl = null;
    description = null;
    edit = false;
    notifyListeners();
  }

  void showSnackBar(String msg, context, {required bool error}) {
    showTopSnackBar(
      Overlay.of(context),
      error == false
          ? CustomSnackBar.success(
              message: msg,
            )
          : CustomSnackBar.error(
              message: msg,
            ),
    );
  }
}
