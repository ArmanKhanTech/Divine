import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:divine/posts/screens/play_video_screen.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:video_player/video_player.dart';

class NewReelsScreen extends StatefulWidget {
  const NewReelsScreen({super.key});

  @override
  State<NewReelsScreen> createState() => _NewReelsScreenState();
}

class _NewReelsScreenState extends State<NewReelsScreen> with WidgetsBindingObserver{
  CameraController? controller;

  String recordingTime = '00:00';

  late Timer timer;
  int start = 0;

  bool isCameraInitialized = false;
  bool isFlashOn = false;
  bool isLensChanging = false;
  bool isVideoRecording = false;
  bool isVideoRecordingPaused = false;
  bool triggerTimerAnimation = false;

  late final List<CameraDescription> cameras;

  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;

  XFile? videoFile;

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras.first, ResolutionPreset.high);
    await onNewCameraSelected(cameras.first);
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    controller = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg
    );

    controller?.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        showSnackBar(msg: 'Camera error : ${controller!.value.errorDescription}');
      }
    });

    controller?.initialize().then((_) {
      if (!mounted) {

        return;
      }
      setState(() {
        isCameraInitialized = true;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (controller == null || !controller!.value.isInitialized) {

      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller!.description);
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: isVideoRecording == false ? AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.clear),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30.0,
          color: Colors.white,
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        title: GradientText(
          'New Reels',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w300,
          ), colors: const [
          Colors.blue,
          Colors.purple,
        ],
        ),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.drive_folder_upload_sharp,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          )
        ],
      ) : AppBar(
          automaticallyImplyLeading: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: isVideoRecordingPaused ? Colors.red : Colors.green,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              recordingTime,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          )
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: isCameraInitialized == true && isLensChanging == false ? Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                cameraWidget(),
                Center(
                  child: triggerTimerAnimation ? Lottie.asset("assets/lottie/timer.json") : Container(),
                ),
              ],
            ),
          ),
          bottomControls(),
          const SizedBox(
            height: 20,
          )
        ],
      ) : Center(child: circularProgress(context, const Color(0xFF9C27B0)),
      )
    );
  }

  Widget cameraWidget(){

    if(controller == null || !controller!.value.isInitialized){

      return Container();
    }

    return CameraPreview(controller!);
  }

  Widget bottomControls(){

    return SizedBox(
      height: 100,
      child: Row(
        children: [
          const Spacer(),
          IconButton(
            onPressed: () {
              if (controller!.value.isInitialized) {
                controller!.setFlashMode(isFlashOn == false ? FlashMode.torch : FlashMode.off);
                setState(() {
                  isFlashOn = !isFlashOn;
                });
              }
            },
            icon: isFlashOn == false ? const Icon(
              Icons.flash_on,
              color: Colors.white,
              size: 30,
            ) : const Icon(
              Icons.flash_off,
              color: Colors.white,
              size: 30,
            ),
          ),
          const Spacer(),
          Container(
            height: 60,
            width: isVideoRecording ? 120 : 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                const Spacer(),
                Center(
                  child: IconButton(
                    onPressed: () {
                      if (controller!.value.isInitialized) {
                        if (isVideoRecording == false) {
                          setState(() {
                            triggerTimerAnimation = true;
                          });
                          Timer(const Duration(seconds: 3), () {
                            startVideoRecording().then((value) => {
                              if (mounted) {
                                setState(() {
                                  triggerTimerAnimation = false;
                                  isVideoRecording = true;
                                  startTimer(start);
                                })
                              }
                            });
                          });
                        } else {
                          stopVideoRecording().then((XFile? video) => {
                            if (mounted) {
                              setState(() {
                                isVideoRecording = false;
                                cancelTimer();
                              }),
                              if (video != null) {
                                videoFile = video,
                                Navigator.push(context, CupertinoPageRoute(
                                    builder: (_) => PlayVideoScreen(filePath: videoFile!.path)))
                              }
                            }
                          });
                        }
                      }
                    },
                    icon: Icon(
                      isVideoRecording == false ? Icons.circle : Icons.stop,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
                isVideoRecording == true ? const Spacer() : Container(),
                isVideoRecording == true ? Container(
                  width: 1,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  )
                ) : Container(),
                isVideoRecording == true ? const Spacer() : Container(),
                isVideoRecording == true ? Center(
                  child: IconButton(
                    onPressed: () {
                      if (controller!.value.isInitialized) {
                        if (isVideoRecordingPaused == false) {
                          pauseVideoRecording().then((value) => {
                            if (mounted) {
                              setState(() {
                                isVideoRecordingPaused = true;
                                pauseTimer();
                              })
                            }
                          });
                        } else {
                          resumeVideoRecording().then((value) => {
                            if (mounted) {
                              setState(() {
                                isVideoRecordingPaused = false;
                                resumeTimer();
                              })
                            }
                          });
                        }
                      }
                    },
                    icon: Icon(
                      !isVideoRecordingPaused ? CupertinoIcons.pause : Icons.play_arrow_sharp,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                ) : Container(),
                const Spacer(),
              ],
            )
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              if (cameras.length <= 2) {

                return;
              }

              final lensDirection = controller?.description.lensDirection;
              if (lensDirection == CameraLensDirection.front)
              {
                setState(() {
                  isLensChanging = true;
                  controller = CameraController(
                    cameras.first,
                    ResolutionPreset.max,
                  );
                });
              }
              else
              {
                setState(() {
                  isLensChanging = true;
                  controller = CameraController(
                    cameras.last,
                    ResolutionPreset.max,
                  );
                });
              }

              controller?.initialize().then((_) {
                if (!mounted) {

                  return;
                }
                setState(() {
                  isLensChanging = false;
                });
              });
            },
            icon: const Icon(
              Icons.flip_camera_ios,
              color: Colors.white,
              size: 30,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {

      return;
    }

    if (cameraController.value.isRecordingVideo) {

      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      showSnackBar(msg: e.description.toString());

      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {

      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      showSnackBar(msg: e.description.toString());

      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {

      return;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      showSnackBar(msg: e.description.toString());

      return;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {

      return;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      showSnackBar(msg: e.description.toString());

      return;
    }
  }

  void startTimer(int timerDuration) {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec,
          (Timer timer) => setState(() {
          if (start > 300) {
            // TODO: Stop recording 5min limit
            timer.cancel();
          } else {
            start = start + 1;
            setState(() {
              recordingTime = intToTime(start);
            });
          }
        },
      ),
    );
  }

  void pauseTimer() {
    timer.cancel();
  }

  void resumeTimer() => startTimer(start);

  void cancelTimer() {
    timer.cancel();
    setState(() {
      start = 0;
      recordingTime = "00:00";
    });
  }

  String intToTime(int value) {
    int h, m, s;

    h = value ~/ 3600;
    m = ((value + h * 3600)) ~/ 60;
    s = value + (h * 3600) + (m * 60);

    String minuteLeft = m.toString().length < 2 ? "0$m" : m.toString();
    String secondsLeft = s.toString().length < 2 ? "0$s" : s.toString();
    String result = "$minuteLeft:$secondsLeft";

    return result;
  }

  showSnackBar({required String msg}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.white)), backgroundColor: Colors.blue,
        behavior: kIsWeb == true ? SnackBarBehavior.fixed : SnackBarBehavior.floating, duration: const Duration(seconds: 2), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: kIsWeb == true ? BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ) : BorderRadius.all(Radius.circular(30)),
        )
    ));
  }
}

