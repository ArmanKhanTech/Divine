import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/screens/main_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
        progressIndicator: circularProgress(context, const Color(0xFFFFFFFF)),
        color: Colors.black,
        opacity: 0.5,
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
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
            List storyList = snapshot.docs;
            DocumentSnapshot storyListSnapshot = storyList[0];
            String url = await uploadMedia(widget.uri);
            StoryModel story = StoryModel(
              url: url,
              time: Timestamp.now(),
              storyId: uuid.v1(),
              viewers: [],
            );
            await viewModel.sendStory(story, storyListSnapshot.id);
            setState(() {
              loading = false;
            });
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (_) => const MainScreen(),
              ),
            );
          } else {
            String url = await uploadMedia(widget.uri);
            StoryModel story = StoryModel(
              url: url,
              time: Timestamp.now(),
              storyId: uuid.v1(),
              viewers: [],
            );
            String id = await viewModel.sendFirstStory(story);
            await viewModel.sendStory(story, id);
            setState(() {
              loading = false;
            });
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                builder: (_) => const MainScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  // Compress & Upload media to Firebase Storage.
  Future<String> uploadMedia(String imagePath) async {
    final imageUri = Uri.parse(imagePath);
    final String outputUri = imageUri.resolve('./output.png').toString();

    XFile? result = (await FlutterImageCompress.compressAndGetFile(
      imagePath, outputUri,
      format: CompressFormat.png,
      quality: 35,
    ));

    File image = File(result!.path);

    Reference storageReference =
    storage.ref().child("status").child(uuid.v1()).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();

    return imageUrl;
  }
}