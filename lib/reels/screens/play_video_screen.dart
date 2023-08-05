import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:video_player/video_player.dart';

// TODO: Continue from here
class PlayVideoScreen extends StatefulWidget {
  final String filePath;

  const PlayVideoScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  State<PlayVideoScreen> createState() => _PlayVideoScreenState();
}

class _PlayVideoScreenState extends State<PlayVideoScreen> {
  late VideoPlayerController videoPlayerController;

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  Future initVideoPlayer() async {
    videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await videoPlayerController.initialize();
    await videoPlayerController.setLooping(true);
    await videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: GradientText(
          'Preview',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w300,
          ), colors: const [
          Colors.blue,
          Colors.purple,
        ],
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30.0,
          color: Colors.white,
        ),
        elevation: 0,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              //
            },
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {

            return const Center(child: CircularProgressIndicator());
          } else {

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    color: Colors.black,
                  ),
                  height: MediaQuery.of(context).size.height * 0.6,
                  child : VideoPlayer(videoPlayerController),
                )
              );
            }
          })
    );
  }
}