import 'dart:async';
import 'dart:io';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:video_player/video_player.dart';

import 'package:divine/modules/reels/screens/pick_from_gallery_screen_reels.dart';
import 'package:divine/widgets/progress_indicator.dart';

import '../../../plugins/story_editor/presentation/widgets/animated_on_tap_button.dart';
import '../../../plugins/video_editor/screens/video_editor.dart';

class NewReelsScreen extends StatefulWidget {
  const NewReelsScreen({super.key});

  @override
  State<NewReelsScreen> createState() => _NewReelsScreenState();
}

class _NewReelsScreenState extends State<NewReelsScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
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
  bool enableAudio = true;

  late final List<CameraDescription> cameras;

  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;

  double minAvailableExposureOffset = 0.0;
  double maxAvailableExposureOffset = 0.0;
  double currentExposureOffset = 0.0;
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentScale = 1.0;
  double baseScale = 1.0;

  int pointers = 0;

  Future<void> initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras.first, ResolutionPreset.high);
    await onNewCameraSelected(cameras.first);
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    controller = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: enableAudio,
    );

    controller?.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        showSnackBar(
            msg: 'Camera error : ${controller!.value.errorDescription}');
      }
    });

    controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller
          ?.getMinExposureOffset()
          .then((double value) => minAvailableExposureOffset = value);
      controller
          ?.getMaxExposureOffset()
          .then((double value) => maxAvailableExposureOffset = value);
      controller?.setFlashMode(FlashMode.off);
      controller
          ?.getMinZoomLevel()
          .then((double value) => minAvailableZoom = value);
      controller
          ?.getMaxZoomLevel()
          .then((double value) => maxAvailableZoom = value);
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

  Future<dynamic> exitDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierColor: Colors.black38,
        barrierDismissible: true,
        builder: (c) => Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetAnimationDuration: const Duration(milliseconds: 300),
              insetAnimationCurve: Curves.ease,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: BlurryContainer(
                  height: 240,
                  color: Colors.black.withOpacity(0.15),
                  blur: 5,
                  padding: const EdgeInsets.all(20),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Cancel?',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "If you go back now, you'll lose all the edits you've made.",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                            letterSpacing: 0.1),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      AnimatedOnTapButton(
                        onTap: () async {
                          if (mounted) {
                            Navigator.pop(c, true);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.redAccent.shade200,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 22,
                        child: Divider(
                          color: Colors.white,
                        ),
                      ),
                      AnimatedOnTapButton(
                        onTap: () {
                          Navigator.pop(c, true);
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (onPopInvoked) async {
        if (onPopInvoked) {
          if (isVideoRecording == true) {
            exitDialog(context);
          }
          // return isVideoRecording == false ? true : false;
        }
      },
      child: Scaffold(
          appBar: isVideoRecording == false
              ? AppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: const Icon(CupertinoIcons.chevron_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    iconSize: 30.0,
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 2.0),
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
                    'Create a Reel',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                    ),
                    colors: const [
                      Colors.blue,
                      Colors.purple,
                    ],
                  ),
                )
              : AppBar(
                  automaticallyImplyLeading: false,
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Colors.black,
                    statusBarIconBrightness: Brightness.light,
                    systemNavigationBarColor: Colors.black,
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  title: Container(
                    height: 35,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: isVideoRecordingPaused
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GradientText(
                      recordingTime,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      ),
                      colors: const [
                        Colors.blue,
                        Colors.purple,
                      ],
                    ),
                  )),
          backgroundColor: Colors.black,
          body: isCameraInitialized == true && isLensChanging == false
              ? Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          cameraWidget(),
                          isVideoRecording == false
                              ? Positioned(
                                  left: 15,
                                  bottom:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: leftControls())
                              : Container(),
                          Center(
                            child: triggerTimerAnimation
                                ? Lottie.asset("assets/lottie/timer.json")
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                    bottomControls(),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Center(
                    child: circularProgress(context, const Color(0xFF9C27B0)),
                  ))),
    );
  }

  Widget cameraWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    final size = MediaQuery.of(context).size;

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Listener(
            onPointerDown: (_) => pointers++,
            onPointerUp: (_) => pointers--,
            child: Transform.scale(
              scale: 1,
              child: AspectRatio(
                aspectRatio: size.aspectRatio,
                child: CameraPreview(
                  controller!,
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: handleScaleStart,
                      onScaleUpdate: handleScaleUpdate,
                      onTapDown: (TapDownDetails details) =>
                          onViewFinderTap(details, constraints),
                    );
                  }),
                ),
              ),
            )),
      ),
    );
  }

  void handleScaleStart(ScaleStartDetails details) {
    baseScale = currentScale;
  }

  Future<void> handleScaleUpdate(ScaleUpdateDetails details) async {
    if (controller == null || pointers != 2) {
      return;
    }

    currentScale =
        (baseScale * details.scale).clamp(minAvailableZoom, maxAvailableZoom);

    await controller!.setZoomLevel(currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Widget bottomControls() {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          const Spacer(),
          IconButton(
            onPressed: () {
              if (controller!.value.isInitialized) {
                controller!.setFlashMode(
                    isFlashOn == false ? FlashMode.torch : FlashMode.off);
                setState(() {
                  isFlashOn = !isFlashOn;
                });
              }
            },
            icon: isFlashOn == false
                ? const Icon(
                    Icons.flash_on,
                    color: Colors.white,
                    size: 30,
                  )
                : const Icon(
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
                                    if (mounted)
                                      {
                                        setState(() {
                                          triggerTimerAnimation = false;
                                          isVideoRecording = true;
                                          startTimer(start);
                                        })
                                      }
                                  });
                            });
                          } else {
                            stopVideoRecording().then((XFile? video) {
                              if (mounted) {
                                setState(() {
                                  isVideoRecording = false;
                                  isVideoRecordingPaused = false;
                                });
                                if (video != null) {
                                  if (video.path.isNotEmpty) {
                                    if (start > 180 || start < 15) {
                                      showSnackBar(
                                          msg:
                                              "Video should be between 15 seconds to 3 minutes.");
                                      File(video.path).delete();
                                    } else {
                                      if (controller!.value.isInitialized) {
                                        controller!.setFlashMode(FlashMode.off);
                                        setState(() {
                                          isFlashOn = false;
                                        });
                                      }
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => VideoEditor(
                                                  file: File(video.path))));
                                    }
                                    cancelTimer();
                                  }
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
                  isVideoRecording == true
                      ? Container(
                          width: 1,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ))
                      : Container(),
                  isVideoRecording == true ? const Spacer() : Container(),
                  isVideoRecording == true
                      ? Center(
                          child: IconButton(
                            onPressed: () {
                              if (controller!.value.isInitialized) {
                                if (isVideoRecordingPaused == false) {
                                  pauseVideoRecording().then((value) => {
                                        if (mounted)
                                          {
                                            setState(() {
                                              isVideoRecordingPaused = true;
                                              pauseTimer();
                                            })
                                          }
                                      });
                                } else {
                                  resumeVideoRecording().then((value) => {
                                        if (mounted)
                                          {
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
                              !isVideoRecordingPaused
                                  ? CupertinoIcons.pause
                                  : Icons.play_arrow_sharp,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        )
                      : Container(),
                  const Spacer(),
                ],
              )),
          const Spacer(),
          IconButton(
            onPressed: () {
              if (cameras.length <= 2) {
                return;
              }

              final lensDirection = controller?.description.lensDirection;
              if (lensDirection == CameraLensDirection.front) {
                setState(() {
                  isLensChanging = true;
                  controller = CameraController(
                    cameras.first,
                    ResolutionPreset.max,
                  );
                });
              } else {
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

  Widget leftControls() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              if (controller!.value.isInitialized) {
                controller!.setFlashMode(FlashMode.off);
                setState(() {
                  isFlashOn = false;
                });
              }
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => const PickFromGalleryScreenReels()));
            },
            icon: const Icon(
              Icons.add_a_photo_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(0),
            icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute,
                color: Colors.white, size: 30),
            color: Colors.white,
            onPressed: controller != null ? onAudioModeButtonPressed : null,
          ),
          const SizedBox(
            height: 5,
          ),
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
    timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (start > 300) {
            showSnackBar(
                msg: "Video should be between 15 seconds to 3 minutes.");
            stopVideoRecording().then((XFile? video) {
              if (mounted) {
                setState(() {
                  isVideoRecording = false;
                });
                if (video != null) {
                  if (video.path.isNotEmpty) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            VideoEditor(file: File(video.path))));
                    cancelTimer();
                  }
                }
              }
            });
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

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  void showSnackBar({required String msg}) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: msg,
      ),
    );
  }
}
