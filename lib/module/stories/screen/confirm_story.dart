// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/screens/main_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_nude_detector/flutter_nude_detector.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../../model/story_model.dart';
import '../../../utility/firebase.dart';
import '../../../viewmodel/user/story_view_model.dart';
import '../../../widget/progress_indicators.dart';

class ConfirmStory extends StatefulWidget {
  final String uri;

  const ConfirmStory({required this.uri, super.key});

  @override
  State<ConfirmStory> createState() => _ConfirmStoryState();
}

class _ConfirmStoryState extends State<ConfirmStory>
    with TickerProviderStateMixin {
  bool loading = false;

  AnimationController? animationController;

  @override
  void dispose() {
    if (animationController != null) {
      animationController!.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  // TODO : Add location, mentions
  @override
  Widget build(BuildContext context) {
    StoryViewModel viewModel = Provider.of<StoryViewModel>(context);

    final File image = File(widget.uri);

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    return LoadingOverlay(
        isLoading: loading,
        progressIndicator: circularProgress(context, const Color(0xFFFFFFFF)),
        color: Colors.black,
        opacity: 0.5,
        child: Scaffold(
          appBar: AppBar(
            title: GradientText(
              'Upload Story',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w300,
              ),
              colors: const [
                Colors.blue,
                Colors.purple,
              ],
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.chevron_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
              iconSize: 30.0,
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 2.0),
            ),
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15, left: 5),
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      loading = true;
                    });
                    final hasNudity =
                        await FlutterNudeDetector.detect(path: widget.uri);
                    if (hasNudity) {
                      setState(() {
                        loading = false;
                      });
                      viewModel.showSnackBar('NSFW content detected.', context,
                          error: true);
                      image.delete();
                      Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                              builder: (_) => const MainScreen()),
                          (route) => false);
                    } else {
                      QuerySnapshot snapshot = await storyRef
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
                        viewModel.showSnackBar(
                            'Story uploaded successfully.', context,
                            error: false);
                        setState(() {
                          loading = false;
                        });
                        image.delete();
                        Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(
                                builder: (_) => const MainScreen()),
                            (route) => false);
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
                        viewModel.showSnackBar(
                            'Story uploaded successfully.', context,
                            error: false);
                        setState(() {
                          loading = false;
                        });
                        image.delete();
                        Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(
                                builder: (_) => const MainScreen()),
                            (route) => false);
                      }
                    }
                  },
                  child: LottieBuilder.asset(
                    'assets/lottie/done.json',
                    height: 32,
                    width: 32,
                    fit: BoxFit.fitWidth,
                    controller: animationController,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black,
          body: SizedBox(
              child: Column(
            children: [
              SizedBox(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  height: MediaQuery.of(context).size.height * .8,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              )),
            ],
          )),
        ));
  }

  Future<String> uploadMedia(String imagePath) async {
    final imageUri = Uri.parse(imagePath);

    final String outputUri = imageUri.resolve('./output.png').toString();

    XFile? result = (await FlutterImageCompress.compressAndGetFile(
      imagePath,
      outputUri,
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
