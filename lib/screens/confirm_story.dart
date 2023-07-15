import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divine/screens/main_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../models/story_model.dart';
import '../utilities/firebase.dart';
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

    return Scaffold(
      appBar:  AppBar(
        title: GradientText(
            'Upload Story',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w300,
            ), colors: const [
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
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: null,
        ),
      ),
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: LoadingOverlay(
          isLoading: loading,
          progressIndicator: circularProgress(context, const Color(0xFFFFFFFF)),
          color: Colors.black,
          opacity: 0.5,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: FileImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 6),
                  child: Container(
                      height: MediaQuery.of(context).size.height * .06,
                      width: MediaQuery.of(context).size.width * .96,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        color: Colors.black12,
                      ),
                      child: Center(
                        widthFactor: 100,
                        child: FloatingActionButton(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )
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
                      )
                  ),
                )
              ),
            ],
          )
        ),
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
