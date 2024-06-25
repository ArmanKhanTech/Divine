// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:divine/plugin/image_editor/utilities/utilities.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor/image_editor.dart' as image_editor;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../stories_editor/presentation/widgets/animated_on_tap_button.dart';
import '../../module/posts/screen/confirm_post_screen.dart';

import 'data/image_item.dart';
import 'data/layer.dart';
import 'layers/background_blur_layer.dart';
import 'layers/background_layer.dart';
import 'layers/emoji_layer.dart';
import 'layers/image_layer.dart';
import 'layers/text_layer.dart';
import 'widgets/loading_screen.dart';
import 'modules/all_emojies.dart';
import 'modules/color_picker.dart';
import 'modules/text_overlay_screen.dart';

late Size viewportSize;

double viewportRatio = 1;

List<Layer> layers = [], undoLayers = [], removedLayers = [];
Map<String, String> _translations = {};

String i18n(String sourceString) =>
    _translations[sourceString.toLowerCase()] ?? sourceString;

ThemeData theme = ThemeData(
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    surface: Colors.black,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black87,
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    toolbarTextStyle: TextStyle(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
  ),
);

class MultiImageEditor extends StatefulWidget {
  final List images;
  final List<AspectRatioOption> cropAvailableRatios;

  final int maxLength;
  final bool allowGallery, allowCamera, allowMultiple;
  final ImageEditorFeatures features;

  const MultiImageEditor({
    super.key,
    this.images = const [],
    @Deprecated('Use features instead') this.allowCamera = false,
    @Deprecated('Use features instead') this.allowGallery = false,
    this.allowMultiple = false,
    this.maxLength = 99,
    this.features = const ImageEditorFeatures(
      pickFromGallery: true,
      captureFromCamera: true,
      crop: true,
      blur: true,
      brush: true,
      emoji: true,
      filters: true,
      flip: true,
      rotate: true,
      text: true,
    ),
    this.cropAvailableRatios = const [
      AspectRatioOption(title: 'Freeform'),
      AspectRatioOption(title: '1:1', ratio: 1),
      AspectRatioOption(title: '4:3', ratio: 4 / 3),
      AspectRatioOption(title: '5:4', ratio: 5 / 4),
      AspectRatioOption(title: '7:5', ratio: 7 / 5),
      AspectRatioOption(title: '16:9', ratio: 16 / 9),
    ],
  });

  @override
  createState() => MultiImageEditorState();
}

class MultiImageEditorState extends State<MultiImageEditor> {
  List<ImageItem> images = [];
  List<File> saveImages = [];

  int index = 0;

  final List<AspectRatioOption> availableRatios = const [
    AspectRatioOption(title: '1:1', ratio: 1),
    AspectRatioOption(title: '4:3', ratio: 4 / 3),
    AspectRatioOption(title: '5:4', ratio: 5 / 4),
    AspectRatioOption(title: '7:5', ratio: 7 / 5),
    AspectRatioOption(title: '16:9', ratio: 16 / 9),
  ];

  double? aspectRatio;
  double? aspectRatioOriginal;

  bool isLandscape = true;

  int rotateAngle = 0;

  List<GlobalKey<ExtendedImageEditorState>> editorKey = [];

  @override
  void initState() {
    images = widget.images.map((e) => ImageItem(e)).toList();
    aspectRatio = aspectRatioOriginal = 1;
    for (int i = 0; i < images.length; i++) {
      editorKey.add(GlobalKey<ExtendedImageEditorState>());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageRatioButton(double? ratio, String title) {
      return TextButton(
        onPressed: () {
          aspectRatioOriginal = ratio;
          if (aspectRatioOriginal != null && isLandscape == false) {
            aspectRatio = 1 / aspectRatioOriginal!;
          } else {
            aspectRatio = aspectRatioOriginal;
          }
          setState(() {});
        },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              i18n(title),
              style: TextStyle(
                fontSize: 20,
                color:
                    aspectRatioOriginal == ratio ? Colors.white : Colors.grey,
              ),
            )),
      );
    }

    Future<Uint8List?> cropImageDataWithNativeLibrary(
        {required ExtendedImageEditorState state}) async {
      final Rect? cropRect = state.getCropRect();
      final EditActionDetails action = state.editAction!;
      final int rotateAngle = action.rotateAngle.toInt();
      final bool flipHorizontal = action.flipY;
      final bool flipVertical = action.flipX;
      final Uint8List img = state.rawImageData;
      final option = image_editor.ImageEditorOption();

      if (action.needCrop) {
        option.addOption(image_editor.ClipOption.fromRect(cropRect!));
      }

      if (action.needFlip) {
        option.addOption(image_editor.FlipOption(
            horizontal: flipHorizontal, vertical: flipVertical));
      }

      if (action.hasRotateAngle) {
        option.addOption(image_editor.RotateOption(rotateAngle));
      }

      final Uint8List? result = await image_editor.ImageEditor.editImage(
        image: img,
        imageEditorOption: option,
      );
      return result;
    }

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
          padding: const EdgeInsets.only(bottom: 3),
        ),
        title: Text(
          i18n('Customize'),
          style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(left: 10, right: 22),
            icon: const Icon(Icons.done, color: Colors.white, size: 30),
            onPressed: () async {
              final tempDir = await getTemporaryDirectory();
              for (int i = 0; i < images.length; i++) {
                final Uint8List? result = await cropImageDataWithNativeLibrary(
                  state: editorKey[i].currentState!,
                );
                if (result == null) {
                  return;
                }
                images[i].load(result);
                File media = await File(
                        '${tempDir.path}/divine${DateTime.timestamp()}image[$i].png')
                    .create();
                media.writeAsBytesSync(images[i].image);
                saveImages.add(media);
              }
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ConfirmSinglePostScreen(
                      postImages: saveImages,
                    ),
                  ));
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 32),
                  for (var image in images)
                    Builder(
                      builder: (BuildContext context) {
                        index = images.indexOf(image);
                        return Container(
                          margin: const EdgeInsets.only(
                              top: 32, right: 32, bottom: 32),
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 1,
                              color: Colors.white,
                            ),
                            color: Colors.black,
                          ),
                          child: Stack(alignment: Alignment.center, children: [
                            GestureDetector(
                                onTap: () async {
                                  var img = await Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => SingleImageEditor(
                                        image: image,
                                        multiImages: true,
                                      ),
                                    ),
                                  );
                                  if (img != null) {
                                    image.load(img);
                                    setState(() {});
                                  }
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: ExtendedImage.memory(
                                      image.image,
                                      cacheRawData: true,
                                      fit: BoxFit.contain,
                                      mode: ExtendedImageMode.editor,
                                      extendedImageEditorKey: editorKey[index],
                                      initEditorConfigHandler: (state) {
                                        return EditorConfig(
                                          cornerColor: Colors.white,
                                          cropAspectRatio: aspectRatio,
                                          lineColor: Colors.white,
                                          editorMaskColorHandler:
                                              (context, pointerDown) {
                                            return Colors.transparent;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                )),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                height: 32,
                                width: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(60),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: IconButton(
                                  iconSize: 20,
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () {
                                    images.remove(image);
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.clear_outlined,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              left: 1,
                              child: Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(100),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                                child: IconButton(
                                  iconSize: 30,
                                  padding: const EdgeInsets.all(5),
                                  onPressed: () async {
                                    Uint8List? editedImage =
                                        await Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => ImageFilters(
                                          image: image.image,
                                        ),
                                      ),
                                    );
                                    if (editedImage != null) {
                                      image.load(editedImage);
                                    }
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.photo_filter_outlined,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ]),
                        );
                      },
                    )
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 80,
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (aspectRatioOriginal != null &&
                          aspectRatioOriginal != 1)
                        IconButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          icon: Icon(
                            Icons.portrait,
                            size: 25,
                            color: isLandscape ? Colors.grey : Colors.white,
                          ),
                          onPressed: () {
                            isLandscape = false;
                            if (aspectRatioOriginal != null) {
                              aspectRatio = 1 / aspectRatioOriginal!;
                            }
                            setState(() {});
                          },
                        ),
                      if (aspectRatioOriginal != null &&
                          aspectRatioOriginal != 1)
                        IconButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          icon: Icon(
                            Icons.landscape,
                            size: 25,
                            color: isLandscape ? Colors.white : Colors.grey,
                          ),
                          onPressed: () {
                            isLandscape = true;
                            aspectRatio = aspectRatioOriginal!;
                            setState(() {});
                          },
                        ),
                      for (var ratio in availableRatios)
                        imageRatioButton(ratio.ratio, i18n(ratio.title)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SingleImageEditor extends StatefulWidget {
  final Directory? savePath;
  final dynamic image;
  final List? imageList;
  final bool allowCamera, allowGallery, multiImages;
  final ImageEditorFeatures features;
  final List<AspectRatioOption> cropAvailableRatios;

  const SingleImageEditor({
    super.key,
    this.savePath,
    this.image,
    this.imageList,
    @Deprecated('Use features instead') this.allowCamera = false,
    @Deprecated('Use features instead') this.allowGallery = false,
    this.features = const ImageEditorFeatures(
      pickFromGallery: true,
      captureFromCamera: true,
      crop: true,
      blur: true,
      brush: true,
      emoji: true,
      filters: true,
      flip: true,
      rotate: true,
      text: true,
    ),
    this.cropAvailableRatios = const [
      AspectRatioOption(title: 'Freeform'),
      AspectRatioOption(title: '1:1', ratio: 1),
      AspectRatioOption(title: '4:3', ratio: 4 / 3),
      AspectRatioOption(title: '5:4', ratio: 5 / 4),
      AspectRatioOption(title: '7:5', ratio: 7 / 5),
      AspectRatioOption(title: '16:9', ratio: 16 / 9),
    ],
    required this.multiImages,
  });

  @override
  createState() => SingleImageEditorState();
}

class SingleImageEditorState extends State<SingleImageEditor> {
  ImageItem currentImage = ImageItem();

  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;

  final scaffoldGlobalKey = GlobalKey<ScaffoldState>();

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();

  ScreenshotController screenshotController = ScreenshotController();

  late Color topLeftColor, bottomRightColor;

  @override
  void dispose() {
    layers.clear();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.image != null) {
      loadImage(widget.image!);
    }
    setState(() {});
    super.initState();
  }

  double flipValue = 0;
  int rotateValue = 0;

  double x = 0;
  double y = 0;
  double z = 0;

  double lastScaleFactor = 1, scaleFactor = 1;
  double widthRatio = 1, heightRatio = 1, pixelRatio = 1;

  void resetTransformation() {
    scaleFactor = 1;
    x = 0;
    y = 0;
    setState(() {});
  }

  Future<Uint8List?> getMergedImage() async {
    if (layers.length == 1 && layers.first is BackgroundLayerData) {
      return (layers.first as BackgroundLayerData).file.image;
    } else if (layers.length == 1 && layers.first is ImageLayerData) {
      return (layers.first as ImageLayerData).image.image;
    }

    return screenshotController.capture(
      pixelRatio: pixelRatio,
    );
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
                  height: 250,
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
    viewportSize = MediaQuery.of(context).size;

    var layersStack = Stack(
      children: layers.map<Widget>((layerItem) {
        if (layerItem is BackgroundLayerData) {
          return BackgroundLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is ImageLayerData) {
          return ImageLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is BackgroundBlurLayerData && layerItem.radius > 0) {
          return BackgroundBlurLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is EmojiLayerData) {
          return EmojiLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is TextLayerData) {
          return TextLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        return Container();
      }).toList(),
    );

    widthRatio = currentImage.width / viewportSize.width;
    heightRatio = currentImage.height / viewportSize.height;
    pixelRatio = math.max(heightRatio, widthRatio);

    return PopScope(
      onPopInvoked: (onPopInvoked) async {
        if (onPopInvoked) {
          return await exitDialog(context);
        }
      },
      child: Scaffold(
        key: scaffoldGlobalKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.chevron_back),
            onPressed: () {
              exitDialog(context);
            },
            iconSize: 30.0,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 3),
          ),
          title: Text(
            i18n('Edit'),
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(Icons.undo,
                  size: 30,
                  color: layers.length > 1 || removedLayers.isNotEmpty
                      ? Colors.white
                      : Colors.grey),
              onPressed: () {
                if (removedLayers.isNotEmpty) {
                  layers.add(removedLayers.removeLast());
                  setState(() {});
                  return;
                }

                if (layers.length <= 1) {
                  return; // do not remove image layer
                }

                undoLayers.add(layers.removeLast());
                setState(() {});
              },
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(Icons.redo,
                  size: 30,
                  color: undoLayers.isNotEmpty ? Colors.white : Colors.grey),
              onPressed: () {
                if (undoLayers.isEmpty) {
                  return;
                }

                layers.add(undoLayers.removeLast());
                setState(() {});
              },
            ),
            IconButton(
              padding: const EdgeInsets.only(left: 10, right: 22),
              icon: const Icon(Icons.done, color: Colors.white, size: 30),
              onPressed: () async {
                resetTransformation();
                setState(() {});
                LoadingScreen(scaffoldGlobalKey).show();
                var binaryIntList =
                    await screenshotController.capture(pixelRatio: pixelRatio);
                LoadingScreen(scaffoldGlobalKey).hide();

                if (mounted) {
                  if (!widget.multiImages) {
                    final convertedImage = await ImageUtils.convert(
                      binaryIntList!,
                      format: 'png',
                      quality: 75,
                    );

                    final tempDir = await getTemporaryDirectory();
                    File media = await File(
                            '${tempDir.path}/divine${DateTime.timestamp()}image.png')
                        .create();
                    media.writeAsBytesSync(convertedImage);
                    Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ConfirmSinglePostScreen(
                            postImages: [media],
                          ),
                        ));
                  } else {
                    Navigator.of(context).pop(binaryIntList);
                  }
                }
              },
            ),
          ],
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(currentImage.image),
                fit: BoxFit.cover,
              ),
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
                    child: SizedBox(
                        width: currentImage.width / pixelRatio,
                        height: currentImage.height / pixelRatio,
                        child: Center(
                          child: Screenshot(
                            controller: screenshotController,
                            child: RotatedBox(
                              quarterTurns: rotateValue,
                              child: Transform(
                                transform: Matrix4(
                                  1,
                                  0,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                  x,
                                  y,
                                  0,
                                  1 / scaleFactor,
                                )..rotateY(flipValue),
                                alignment: FractionalOffset.center,
                                child: layersStack,
                              ),
                            ),
                          ),
                        )),
                  ),
                )
              ],
            )),
        bottomNavigationBar: Container(
          alignment: Alignment.bottomCenter,
          height: 78 + MediaQuery.of(context).padding.bottom,
          padding: const EdgeInsets.only(top: 15),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.rectangle,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  BottomButton(
                    icon: CupertinoIcons.slider_horizontal_3,
                    text: 'Adjust',
                    onTap: () async {
                      resetTransformation();
                      LoadingScreen(scaffoldGlobalKey).show();
                      var mergedImage = await getMergedImage();

                      if (!mounted) {
                        return;
                      }

                      Uint8List? adjustedImage = await Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ImageAdjust(
                            image: mergedImage!,
                          ),
                        ),
                      );

                      LoadingScreen(scaffoldGlobalKey).hide();
                      if (adjustedImage == null) {
                        return;
                      }

                      removedLayers.clear();
                      undoLayers.clear();

                      var layer = BackgroundLayerData(
                        file: ImageItem(adjustedImage),
                      );

                      layers.add(layer);
                      await layer.file.status;

                      setState(() {});
                    },
                  ),
                  if (widget.features.crop)
                    BottomButton(
                      icon: Icons.crop,
                      text: 'Crop',
                      onTap: () async {
                        resetTransformation();

                        LoadingScreen(scaffoldGlobalKey).show();
                        var mergedImage = await getMergedImage();
                        LoadingScreen(scaffoldGlobalKey).hide();

                        if (!mounted) {
                          return;
                        }

                        Uint8List? croppedImage = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ImageCropper(
                              image: mergedImage!,
                              availableRatios: widget.cropAvailableRatios,
                            ),
                          ),
                        );

                        if (croppedImage == null) {
                          return;
                        }

                        flipValue = 0;
                        rotateValue = 0;
                        await currentImage.load(croppedImage);

                        setState(() {});
                      },
                    ),
                  if (widget.features.text)
                    BottomButton(
                      icon: Icons.text_fields,
                      text: 'Text',
                      onTap: () async {
                        TextLayerData? layer = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const TextEditorImage(),
                          ),
                        );

                        if (layer == null) {
                          return;
                        }

                        undoLayers.clear();
                        removedLayers.clear();
                        layers.add(layer);

                        setState(() {});
                      },
                    ),
                  if (widget.features.flip)
                    BottomButton(
                      icon: Icons.flip,
                      text: 'Flip',
                      onTap: () {
                        setState(() {
                          flipValue = flipValue == 0 ? math.pi : 0;
                        });
                      },
                    ),
                  if (widget.features.rotate)
                    BottomButton(
                      icon: Icons.rotate_left,
                      text: 'Rotate',
                      onTap: () {
                        var t = currentImage.width;

                        currentImage.width = currentImage.height;
                        currentImage.height = t;
                        rotateValue--;

                        setState(() {});
                      },
                    ),
                  if (widget.features.blur)
                    BottomButton(
                      icon: Icons.blur_on,
                      text: 'Blur',
                      onTap: () {
                        var blurLayer = BackgroundBlurLayerData(
                          color: Colors.transparent,
                          radius: 0.0,
                          opacity: 0.0,
                        );

                        undoLayers.clear();
                        removedLayers.clear();
                        layers.add(blurLayer);

                        setState(() {});

                        showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)),
                          ),
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setS) {
                                return SingleChildScrollView(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20)),
                                        border: Border(
                                          top: BorderSide(
                                              width: 1, color: Colors.white),
                                          bottom: BorderSide(
                                              width: 0, color: Colors.white),
                                          left: BorderSide(
                                              width: 0, color: Colors.white),
                                          right: BorderSide(
                                              width: 0, color: Colors.white),
                                        )),
                                    padding: const EdgeInsets.all(15),
                                    height: 280,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 5.0),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              i18n('Blur Color'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: BarColorPicker(
                                                thumbColor: Colors.white,
                                                cornerRadius: 10,
                                                pickMode: PickMode.color,
                                                colorListener: (int value) {
                                                  setS(() {
                                                    setState(() {
                                                      blurLayer.color =
                                                          Color(value);
                                                    });
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          TextButton(
                                            child: Text(
                                              i18n('Reset'),
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                setS(() {
                                                  blurLayer.color =
                                                      Colors.transparent;
                                                });
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 15),
                                        ]),
                                        const SizedBox(height: 10.0),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              i18n('Blur Radius'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(children: [
                                          Expanded(
                                            child: Slider(
                                              activeColor: Colors.white,
                                              inactiveColor: Colors.grey,
                                              value: blurLayer.radius,
                                              min: 0.0,
                                              max: 10.0,
                                              onChanged: (v) {
                                                setS(() {
                                                  setState(() {
                                                    blurLayer.radius = v;
                                                  });
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          TextButton(
                                            child: Text(
                                              i18n('Reset'),
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18),
                                            ),
                                            onPressed: () {
                                              setS(() {
                                                setState(() {
                                                  blurLayer.radius = 0.0;
                                                });
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 15),
                                        ]),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              i18n('Blur Opacity'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(children: [
                                          Expanded(
                                            child: Slider(
                                              activeColor: Colors.white,
                                              inactiveColor: Colors.grey,
                                              value: blurLayer.opacity,
                                              min: 0.00,
                                              max: 1.0,
                                              onChanged: (v) {
                                                setS(() {
                                                  setState(() {
                                                    blurLayer.opacity = v;
                                                  });
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          TextButton(
                                            child: Text(
                                              i18n('Reset'),
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 18),
                                            ),
                                            onPressed: () {
                                              setS(() {
                                                setState(() {
                                                  blurLayer.opacity = 0.0;
                                                });
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 15),
                                        ]),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  if (widget.features.filters)
                    BottomButton(
                      icon: Icons.photo_filter_outlined,
                      text: 'Filters',
                      onTap: () async {
                        resetTransformation();
                        LoadingScreen(scaffoldGlobalKey).show();
                        var mergedImage = await getMergedImage();

                        if (!mounted) {
                          return;
                        }

                        Uint8List? filterAppliedImage = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ImageFilters(
                              image: mergedImage!,
                            ),
                          ),
                        );

                        LoadingScreen(scaffoldGlobalKey).hide();
                        if (filterAppliedImage == null) {
                          return;
                        }

                        removedLayers.clear();
                        undoLayers.clear();
                        await currentImage.load(filterAppliedImage);

                        setState(() {});
                      },
                    ),
                  if (widget.features.emoji)
                    BottomButton(
                      icon: Icons.emoji_emotions_outlined,
                      text: 'Emoji',
                      onTap: () async {
                        EmojiLayerData? layer = await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)),
                          ),
                          builder: (BuildContext context) {
                            return const Emojies();
                          },
                        );

                        if (layer == null) {
                          return;
                        }

                        undoLayers.clear();
                        removedLayers.clear();
                        layers.add(layer);

                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final picker = ImagePicker();

  Future<void> loadImage(dynamic imageFile) async {
    await currentImage.load(imageFile);

    layers.clear();
    layers.add(BackgroundLayerData(
      file: currentImage,
    ));
    setState(() {});
  }
}

class BottomButton extends StatelessWidget {
  final VoidCallback? onTap, onLongPress;
  final IconData icon;
  final String text;

  const BottomButton({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    double left = 10, right = 10;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.only(
          left: left,
          right: right,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(
              height: 4,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageAdjust extends StatefulWidget {
  final Uint8List image;

  const ImageAdjust({
    super.key,
    required this.image,
  });

  @override
  createState() => ImageAdjustState();
}

class ImageAdjustState extends State<ImageAdjust> {
  ScreenshotController screenshotController = ScreenshotController();

  Uint8List adjustedImage = Uint8List.fromList([]);

  double brightness = 0.0;
  double contrast = 0.0;
  double saturation = 0.0;
  double current = 0;

  String currentFilter = 'Brightness';

  ColorFilterGenerator myFilter =
      ColorFilterGenerator(name: "CustomFilter", filters: [
    ColorFilterAddons.brightness(0),
    ColorFilterAddons.contrast(0),
    ColorFilterAddons.saturation(0),
  ]);

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.only(bottom: 3),
        ),
        title: const Text(
          'Adjust',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(
              left: 10,
              right: 22,
            ),
            icon: const Icon(Icons.check, size: 30, color: Colors.white),
            onPressed: () async {
              var data = await screenshotController.capture();
              if (mounted) Navigator.pop(context, data);
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Screenshot(
          controller: screenshotController,
          child: Stack(
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.matrix(myFilter.matrix),
                child: Image.memory(
                  widget.image,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 105,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: Slider(
                min: 0.0,
                max: 1.0,
                value: current,
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                thumbColor: Colors.white,
                onChanged: (value) {
                  current = value;
                  if (currentFilter == 'Brightness') {
                    brightness = value;
                    myFilter =
                        ColorFilterGenerator(name: "CustomFilter", filters: [
                      ColorFilterAddons.brightness(brightness),
                      ColorFilterAddons.contrast(contrast),
                      ColorFilterAddons.saturation(saturation),
                    ]);
                  } else if (currentFilter == 'Contrast') {
                    contrast = value;
                    myFilter =
                        ColorFilterGenerator(name: "CustomFilter", filters: [
                      ColorFilterAddons.brightness(brightness),
                      ColorFilterAddons.contrast(contrast),
                      ColorFilterAddons.saturation(saturation),
                    ]);
                  } else if (currentFilter == 'Saturation') {
                    saturation = value;
                    myFilter =
                        ColorFilterGenerator(name: "CustomFilter", filters: [
                      ColorFilterAddons.brightness(brightness),
                      ColorFilterAddons.contrast(contrast),
                      ColorFilterAddons.saturation(saturation),
                    ]);
                  }
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BottomButton(
                  icon: CupertinoIcons.brightness,
                  text: 'Brightness',
                  onTap: () async {
                    setState(() {
                      current = brightness;
                      currentFilter = 'Brightness';
                    });
                  },
                ),
                BottomButton(
                  icon: Icons.contrast,
                  text: 'Contrast',
                  onTap: () async {
                    setState(() {
                      current = contrast / 100;
                      currentFilter = 'Contrast';
                    });
                  },
                ),
                BottomButton(
                  icon: CupertinoIcons.circle_grid_hex,
                  text: 'Saturation',
                  onTap: () async {
                    setState(() {
                      current = saturation;
                      currentFilter = 'Saturation';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ImageCropper extends StatefulWidget {
  final Uint8List image;
  final List<AspectRatioOption> availableRatios;

  const ImageCropper({
    super.key,
    required this.image,
    this.availableRatios = const [
      AspectRatioOption(title: 'Freeform'),
      AspectRatioOption(title: '1:1', ratio: 1),
      AspectRatioOption(title: '4:3', ratio: 4 / 3),
      AspectRatioOption(title: '5:4', ratio: 5 / 4),
      AspectRatioOption(title: '7:5', ratio: 7 / 5),
      AspectRatioOption(title: '16:9', ratio: 16 / 9),
    ],
  });

  @override
  createState() => ImageCropperState();
}

class ImageCropperState extends State<ImageCropper> {
  final GlobalKey<ExtendedImageEditorState> _controller =
      GlobalKey<ExtendedImageEditorState>();

  double? aspectRatio;
  double? aspectRatioOriginal;

  bool isLandscape = true;

  int rotateAngle = 0;

  @override
  void initState() {
    if (widget.availableRatios.isNotEmpty) {
      aspectRatio = aspectRatioOriginal = 1;
    }
    _controller.currentState?.rotate(right: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.only(bottom: 3),
        ),
        title: Text(
          i18n('Crop'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.black,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(
              left: 10,
              right: 22,
            ),
            icon: const Icon(Icons.check, size: 30, color: Colors.white),
            onPressed: () async {
              var state = _controller.currentState;
              if (state == null) {
                return;
              }

              var data = await cropImageDataWithNativeLibrary(state: state);
              if (mounted) {
                Navigator.pop(context, data);
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Theme(
        data: theme,
        child: Container(
          color: Colors.black,
          child: ExtendedImage.memory(
            widget.image,
            cacheRawData: true,
            fit: BoxFit.contain,
            extendedImageEditorKey: _controller,
            mode: ExtendedImageMode.editor,
            initEditorConfigHandler: (state) {
              return EditorConfig(
                cornerColor: Colors.white,
                cropAspectRatio: aspectRatio,
                lineColor: Colors.white,
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 80,
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (aspectRatioOriginal != null &&
                          aspectRatioOriginal != 1)
                        IconButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          icon: Icon(
                            Icons.portrait,
                            size: 25,
                            color: isLandscape ? Colors.grey : Colors.white,
                          ),
                          onPressed: () {
                            isLandscape = false;
                            if (aspectRatioOriginal != null) {
                              aspectRatio = 1 / aspectRatioOriginal!;
                            }

                            setState(() {});
                          },
                        ),
                      if (aspectRatioOriginal != null &&
                          aspectRatioOriginal != 1)
                        IconButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          icon: Icon(
                            Icons.landscape,
                            size: 25,
                            color: isLandscape ? Colors.white : Colors.grey,
                          ),
                          onPressed: () {
                            isLandscape = true;
                            aspectRatio = aspectRatioOriginal!;

                            setState(() {});
                          },
                        ),
                      for (var ratio in widget.availableRatios)
                        imageRatioButton(ratio.ratio, i18n(ratio.title)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> cropImageDataWithNativeLibrary(
      {required ExtendedImageEditorState state}) async {
    final Rect? cropRect = state.getCropRect();
    final EditActionDetails action = state.editAction!;
    final int rotateAngle = action.rotateAngle.toInt();
    final bool flipHorizontal = action.flipY;
    final bool flipVertical = action.flipX;
    final Uint8List img = state.rawImageData;
    final option = image_editor.ImageEditorOption();

    if (action.needCrop) {
      option.addOption(image_editor.ClipOption.fromRect(cropRect!));
    }

    if (action.needFlip) {
      option.addOption(image_editor.FlipOption(
          horizontal: flipHorizontal, vertical: flipVertical));
    }

    if (action.hasRotateAngle) {
      option.addOption(image_editor.RotateOption(rotateAngle));
    }

    final Uint8List? result = await image_editor.ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    return result;
  }

  Widget imageRatioButton(double? ratio, String title) {
    return TextButton(
      onPressed: () {
        aspectRatioOriginal = ratio;
        if (aspectRatioOriginal != null && isLandscape == false) {
          aspectRatio = 1 / aspectRatioOriginal!;
        } else {
          aspectRatio = aspectRatioOriginal;
        }

        setState(() {});
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            i18n(title),
            style: TextStyle(
              fontSize: 20,
              color: aspectRatioOriginal == ratio ? Colors.white : Colors.grey,
            ),
          )),
    );
  }
}

class ImageFilters extends StatefulWidget {
  final Uint8List image;
  final bool useCache;

  const ImageFilters({
    super.key,
    required this.image,
    this.useCache = true,
  });

  @override
  createState() => ImageFiltersState();
}

class ImageFiltersState extends State<ImageFilters> {
  late img.Image decodedImage;

  ColorFilterGenerator selectedFilter = PresetFilters.none;

  Uint8List resizedImage = Uint8List.fromList([]);

  double filterOpacity = 1;

  Uint8List filterAppliedImage = Uint8List.fromList([]);

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.only(bottom: 3),
        ),
        title: Text(
          i18n('Filters'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.black,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(
              left: 10,
              right: 22,
            ),
            icon: const Icon(Icons.check, size: 30, color: Colors.white),
            onPressed: () async {
              var data = await screenshotController.capture();
              if (mounted) Navigator.pop(context, data);
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Screenshot(
          controller: screenshotController,
          child: Stack(
            children: [
              Image.memory(
                widget.image,
                fit: BoxFit.cover,
              ),
              FilterAppliedImage(
                image: widget.image,
                filter: selectedFilter,
                fit: BoxFit.cover,
                opacity: filterOpacity,
                onProcess: (img) {
                  filterAppliedImage = img;
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 140,
          child: Column(children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: Slider(
                min: 0,
                max: 1,
                divisions: 100,
                value: filterOpacity,
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                thumbColor: Colors.white,
                onChanged: (value) {
                  filterOpacity = value;
                  setState(() {});
                },
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  for (int i = 0; i < presetFiltersList.length; i++)
                    filterPreviewButton(
                      filter: presetFiltersList[i],
                      name: presetFiltersList[i].name,
                    ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget filterPreviewButton({required filter, required String name}) {
    if (name == 'AddictiveBlue') {
      name = 'Cerulean';
    } else if (name == 'AddictiveRed') {
      name = 'Crimson';
    }

    return GestureDetector(
      onTap: () {
        selectedFilter = filter;
        setState(() {});
      },
      child: Column(children: [
        Container(
          height: 60,
          width: 60,
          margin:
              const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: FilterAppliedImage(
              image: widget.image,
              filter: filter,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          i18n(name),
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ]),
    );
  }
}

class FilterAppliedImage extends StatelessWidget {
  final Uint8List image;
  final ColorFilterGenerator filter;
  final BoxFit? fit;
  final Function(Uint8List)? onProcess;
  final double opacity;

  FilterAppliedImage({
    super.key,
    required this.image,
    required this.filter,
    this.fit,
    this.onProcess,
    this.opacity = 1,
  }) {
    if (onProcess != null) {
      if (filter.filters.isEmpty) {
        onProcess!(image);
        return;
      }

      final image_editor.ImageEditorOption option =
          image_editor.ImageEditorOption();

      option.addOption(image_editor.ColorOption(matrix: filter.matrix));
      image_editor.ImageEditor.editImage(
        image: image,
        imageEditorOption: option,
      ).then((result) {
        if (result != null) {
          onProcess!(result);
        }
      }).catchError((err, stack) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (filter.filters.isEmpty) return Image.memory(image, fit: fit);
    return Opacity(
      opacity: opacity,
      child: filter.build(
        Image.memory(image, fit: fit),
      ),
    );
  }
}
