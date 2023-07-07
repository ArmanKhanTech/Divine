import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../utilities/firebase.dart';
import '../utilities/system_ui.dart';
import '../view_models/user/story_view_model.dart';
import '../widgets/progress_indicators.dart';

// ConfirmStory.
class ConfirmStory extends StatefulWidget {
  final String uri;
  const ConfirmStory({required this.uri, super.key});

  @override
  State<ConfirmStory> createState() => _ConfirmStoryState();
}

class _ConfirmStoryState extends State<ConfirmStory> {
  bool loading = false;

  // UI of ConfirmStory.
  @override
  Widget build(BuildContext context) {
    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);
    final File image = File(widget.uri);

    SystemUI.darkSystemUI();

    return Scaffold(
      body: LoadingOverlay(
        isLoading: loading,
        progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Image.file(image),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () async {
          setState(() {
            loading = true;
          });
          QuerySnapshot snapshot = await statusRef
              .where('userId', isEqualTo: auth.currentUser!.uid)
              .get();
          if (snapshot.docs.isNotEmpty) {
            List chatList = snapshot.docs;
            DocumentSnapshot chatListSnapshot = chatList[0];
            String url = await uploadMedia(viewModel.mediaUrl!);
            StoryModel message = StoryModel(
              url: url,
              time: Timestamp.now(),
              statusId: uuid.v1(),
              viewers: [],
            );
            await viewModel.sendStory(message, chatListSnapshot.id);
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
          } else {
            String url = await uploadMedia(image);
            StoryModel message = StoryModel(
              url: url,
              time: Timestamp.now(),
              statusId: uuid.v1(),
              viewers: [],
            );
            String id = await viewModel.sendFirstStory(message);
            await viewModel.sendStory(message, id);
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<String> uploadMedia(File image) async {
    Reference storageReference =
    storage.ref().child("status").child(uuid.v1()).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }
}