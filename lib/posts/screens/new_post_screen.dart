import 'dart:async';
import 'package:camera/camera.dart';
import 'package:divine/posts/screens/pick_from_gallery_screen_posts.dart';
import 'package:divine/posts/screens/preview_image.dart';
import 'package:divine/widgets/progress_indicators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../view_models/screens/posts_view_model.dart';

class NewPostScreen extends StatefulWidget {
  final String title;

  const NewPostScreen({super.key, required this.title});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> with
    WidgetsBindingObserver, TickerProviderStateMixin{
  CameraController? controller;

  bool isCameraInitialized = false;
  bool isFlashOn = false;
  bool isLensChanging = false;
  bool pictureTaken = false;
  bool exposureLongPress = false;

  late final List<CameraDescription> cameras;

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
    controller = CameraController(widget.title != 'Profile Picture' ?
    cameras.first : cameras.last, ResolutionPreset.high);
    await onNewCameraSelected(widget.title != 'Profile Picture' ?
    cameras.first : cameras.last);
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    setState(() {
      controller = CameraController(
        description,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
    });

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
      controller?.getMinExposureOffset().then(
              (double value) => minAvailableExposureOffset = value);
      controller?.getMaxExposureOffset()
          .then((double value) => maxAvailableExposureOffset = value);
      controller?.setFlashMode(FlashMode.off);
      controller?.getMinZoomLevel().then(
              (double value) => minAvailableZoom = value);
      controller?.getMaxZoomLevel().then(
              (double value) => maxAvailableZoom = value);
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
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    return Scaffold(
        appBar: AppBar(
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
            widget.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w300,
            ), colors: const [
            Colors.blue,
            Colors.purple,
          ]),
        ),
        backgroundColor: Colors.black,
        body: isCameraInitialized == true && isLensChanging == false && pictureTaken == false ? Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  cameraWidget(),
                  Positioned(
                      left: 15,
                      bottom: MediaQuery.of(context).size.height * 0.3,
                      child: leftControls()
                  ),
                  exposureLongPress == true ? Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: exposureControl(),
                      )
                  ) : Container(),
                ],
              ),
            ),
            bottomControls(viewModel),
          ],
        ) : Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Center(child: circularProgress(context, const Color(0xFF9C27B0)))
        ));
  }

  Widget cameraWidget(){

    if(controller == null || !controller!.value.isInitialized){
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
                child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
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
          )
        ),
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

    currentScale = (baseScale * details.scale)
        .clamp(minAvailableZoom, maxAvailableZoom);
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

  Widget exposureControl () {
    return Slider(
      value: currentExposureOffset,
      min: minAvailableExposureOffset,
      max: maxAvailableExposureOffset,
      divisions: 100,
      thumbColor: Colors.white,
      activeColor: Colors.white,
      onChanged: (double value) {
        if (controller!.value.isInitialized) {
          setExposureOffset(value);
        }
      },
      onChangeEnd: (double value) {
        setState(() {
          exposureLongPress = false;
        });
      },
    );
  }

  Widget bottomControls(PostsViewModel viewModel){
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
          GestureDetector(
            onTap: () async {
              setState(() {
                pictureTaken = true;
              });
              final XFile? file = await takePicture();
              if (file == null) {
                showSnackBar(msg: 'Error: No file found');
                setState(() {
                  pictureTaken = false;
                });

                return;
              } else{
                if (controller!.value.isInitialized) {
                  controller!.setFlashMode(FlashMode.off);
                  setState(() {
                    isFlashOn = false;
                  });
                }
                switch (widget.title) {
                  case 'Profile Picture':
                    //
                    break;
                  case 'New Story':
                    //
                    break;
                  case 'New Post':
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => PreviewImage(imageFile: file))).then((value) {
                              setState(() {
                                pictureTaken = false;
                              });
                            });
                    break;
                  default:
                    break;
                }
              }
            },
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () async {
              if (cameras.length <= 2) {
                return;
              }

              final lensDirection = controller?.description.lensDirection;
              if (lensDirection == CameraLensDirection.front) {
                setState(() {
                  isLensChanging = true;
                });

                await onNewCameraSelected(cameras.first);
              } else {
                setState(() {
                  isLensChanging = true;
                });

                await onNewCameraSelected(cameras.last);
              }
              setState(() {
                isLensChanging = false;
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
          const Spacer(),
          IconButton(
            onPressed: () {
              if (controller!.value.isInitialized) {
                controller!.setFlashMode(FlashMode.off);
                setState(() {
                  isFlashOn = false;
                });
              }
              Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const PickFromGalleryScreenPosts()));
            },
            icon: const Icon(
              Icons.add_a_photo_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              if (controller!.value.isInitialized) {
                if (controller!.value.exposureMode == ExposureMode.auto) {
                  setExposureMode(ExposureMode.locked);
                } else {
                  setExposureMode(ExposureMode.auto);
                }
              }
            },
            onLongPress: () {
              setState(() {
                exposureLongPress = true;
              });
            },
            child: Icon(
              Icons.exposure,
              color: controller!.value.exposureMode == ExposureMode.auto ?
              Colors.white : Colors.blue,
              size: 30,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          IconButton(
            onPressed: () {
              if (controller!.value.isInitialized) {
                if (controller!.value.focusMode == FocusMode.auto) {
                  setFocusMode(FocusMode.locked);
                } else {
                  setFocusMode(FocusMode.auto);
                }
              }
            },
            icon: Icon(
              Icons.filter_center_focus_sharp,
              color: controller!.value.focusMode == FocusMode.auto ?
              Colors.white : Colors.red,
              size: 30,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showSnackBar(msg: 'Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      showSnackBar(msg: 'Error: ${e.code}\n${e.description}');
      return null;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException {
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {
      currentExposureOffset = offset;
    });
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException {
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException {
      rethrow;
    }
  }

  showSnackBar({required String msg}) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: msg,
      ),
    );
  }
}