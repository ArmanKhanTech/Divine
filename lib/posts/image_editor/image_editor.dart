import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:divine/posts/image_editor/utilities.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hand_signature/signature.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor/image_editor.dart' as image_editor;
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'data/image_item.dart';
import 'data/layer.dart';
import 'data/color_filter_generator.dart' as color_filter_generator;
import 'layers/background_blur_layer.dart';
import 'layers/background_layer.dart';
import 'layers/emoji_layer.dart';
import 'layers/image_layer.dart';
import 'layers/text_layer.dart';
import 'loading_screen.dart';
import 'modules/all_emojies.dart';
import 'modules/color_picker.dart';
import 'modules/text.dart';

late Size viewportSize;
double viewportRatio = 1;

List<Layer> layers = [], undoLayers = [], removedLayers = [];
Map<String, String> _translations = {};

String i18n(String sourceString) =>
    _translations[sourceString.toLowerCase()] ?? sourceString;

// TODO : Dont allow image above 2MB, implement image adjustment
class ImageEditor extends StatelessWidget {
  final Uint8List? image;

  final List? images;

  final Directory? savePath;

  final int maxLength;

  final bool allowGallery, allowCamera, allowMultiple;

  final ImageEditorFeatures features;

  final List<AspectRatioOption> cropAvailableRatios;

  const ImageEditor({
    super.key,
    this.image,
    this.images,
    this.savePath,
    @Deprecated('Use features instead') this.allowCamera = false,
    @Deprecated('Use features instead') this.allowGallery = false,
    this.allowMultiple = false,
    this.maxLength = 99,
    Color? appBar,
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
  Widget build(BuildContext context) {
    if (images == null &&
        image == null &&
        !features.captureFromCamera &&
        !features.pickFromGallery) {
      throw Exception(
          'No image to work with, provide an image or allow the image picker.');
    }

    if ((image == null || images != null) && allowMultiple == true) {

      return MultiImageEditor(
        images: images ?? [],
        savePath: savePath,
        allowMultiple: allowMultiple,
        maxLength: maxLength,
        features: features,
        cropAvailableRatios: cropAvailableRatios,
      );
    } else {

      return SingleImageEditor(
        image: image,
        savePath: savePath,
        features: features,
        cropAvailableRatios: cropAvailableRatios,
      );
    }
  }

  static i18n(Map<String, String> translations) {
    translations.forEach((key, value) {
      _translations[key.toLowerCase()] = value;
    });
  }

  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      background: Colors.black,
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
}

class MultiImageEditor extends StatefulWidget {
  final Directory? savePath;

  final List images;

  final int maxLength;

  final bool allowGallery, allowCamera, allowMultiple;

  final ImageEditorFeatures features;

  final List<AspectRatioOption> cropAvailableRatios;

  const MultiImageEditor({
    super.key,
    this.images = const [],
    this.savePath,
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
  createState() => _MultiImageEditorState();
}

class _MultiImageEditorState extends State<MultiImageEditor> {
  List<ImageItem> images = [];

  @override
  void initState() {
    images = widget.images.map((e) => ImageItem(e)).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            const BackButton(color: Colors.white),
            const Spacer(),
            if (images.length < widget.maxLength &&
                widget.features.pickFromGallery)
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.photo),
                onPressed: () async {
                  var selected = await picker.pickMultiImage();

                  images.addAll(selected.map((e) => ImageItem(e)).toList());
                  setState(() {});
                },
              ),
            if (images.length < widget.maxLength &&
                widget.features.captureFromCamera)
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.camera_alt),
                onPressed: () async {
                  var selected =
                  await picker.pickImage(source: ImageSource.camera);

                  if (selected == null) return;

                  images.add(ImageItem(selected));
                  setState(() {});
                },
              ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                Navigator.pop(context, images);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 332,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    for (var image in images)
                      Stack(children: [
                        GestureDetector(
                          onTap: () async {
                            var img = await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SingleImageEditor(
                                  image: image,
                                ),
                              ),
                            );
                            if (img != null) {
                              image.load(img);
                              setState(() {});
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                top: 32, right: 32, bottom: 32),
                            width: 200,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border:
                              Border.all(color: Colors.white.withAlpha(80)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                image.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 36,
                          right: 36,
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
                                // print('removing');
                                images.remove(image);
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear_outlined),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 32,
                          left: 0,
                          child: Container(
                            height: 38,
                            width: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(100),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(19),
                              ),
                            ),
                            child: IconButton(
                              iconSize: 20,
                              padding: const EdgeInsets.all(0),
                              onPressed: () async {
                                Uint8List? editedImage = await Navigator.push(
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
                              },
                              icon: const Icon(Icons.photo_filter_sharp),
                            ),
                          ),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final picker = ImagePicker();
}

class SingleImageEditor extends StatefulWidget {
  final Directory? savePath;

  final dynamic image;

  final List? imageList;

  final bool allowCamera, allowGallery;

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
  });

  @override
  createState() => _SingleImageEditorState();
}

class _SingleImageEditorState extends State<SingleImageEditor> {
  ImageItem currentImage = ImageItem();

  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;

  final scaffoldGlobalKey = GlobalKey<ScaffoldState>();

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();

  ScreenshotController screenshotController = ScreenshotController();

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
    super.initState();
  }

  double flipValue = 0;
  int rotateValue = 0;

  double x = 0;
  double y = 0;
  double z = 0;

  double lastScaleFactor = 1, scaleFactor = 1;
  double widthRatio = 1, heightRatio = 1, pixelRatio = 1;

  resetTransformation() {
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

    return Scaffold(
        key: scaffoldGlobalKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          title: Text(
            i18n('Edit'),
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(Icons.undo,
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
                  color: undoLayers.isNotEmpty ? Colors.white : Colors.grey),
              onPressed: () {
                if (undoLayers.isEmpty) {
                  return;
                }
                layers.add(undoLayers.removeLast());
                setState(() {});
              },
            ),
            if (widget.features.pickFromGallery)
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.photo, color: Colors.white),
                onPressed: () async {
                  var image =
                  await picker.pickImage(source: ImageSource.gallery);
                  if (image == null) {
                    return;
                  }
                  loadImage(image);
                },
              ),
            if (widget.features.captureFromCamera)
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () async {
                  var image =
                  await picker.pickImage(source: ImageSource.camera);
                  if (image == null) {
                    return;
                  }
                  loadImage(image);
                },
              ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () async {
                resetTransformation();
                setState(() {});
                LoadingScreen(scaffoldGlobalKey).show();
                var binaryIntList = await screenshotController.capture(pixelRatio: pixelRatio);
                LoadingScreen(scaffoldGlobalKey).hide();
                if (mounted) {
                  Navigator.pop(context, binaryIntList);
                }
              },
            ),
          ],
        ),
        body: Stack(children: [
          GestureDetector(
            onScaleUpdate: (details) {
              if (details.pointerCount == 1) {
                x += details.focalPointDelta.dx;
                y += details.focalPointDelta.dy;
                setState(() {});
              }
              if (details.pointerCount == 2) {
                if (details.horizontalScale != 1) {
                  scaleFactor = lastScaleFactor *
                      math.min(details.horizontalScale, details.verticalScale);
                  setState(() {});
                }
              }
            },
            onScaleEnd: (details) {
              lastScaleFactor = scaleFactor;
            },
            child: Center(
              child: SizedBox(
                height: currentImage.height / pixelRatio,
                width: currentImage.width / pixelRatio,
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
              ),
            ),
          ),
        ]),
        bottomNavigationBar: Container(
          alignment: Alignment.bottomCenter,
          height: 86 + MediaQuery.of(context).padding.bottom,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.black87,
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
                      LoadingScreen(scaffoldGlobalKey).hide();
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
                                          top: BorderSide(width: 1, color: Colors.white),
                                          bottom: BorderSide(width: 0, color: Colors.white),
                                          left: BorderSide(width: 0, color: Colors.white),
                                          right: BorderSide(width: 0, color: Colors.white),
                                        )
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    height: 300,
                                    child: Column(
                                      children: [
                                        Text(
                                          i18n('Slider Color'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                        ),
                                        Row(children: [
                                          Expanded(
                                            child: BarColorPicker(
                                              width: 300,
                                              thumbColor: Colors.white,
                                              cornerRadius: 10,
                                              pickMode: PickMode.color,
                                              colorListener: (int value) {
                                                setS(() {
                                                  setState(() {
                                                    blurLayer.color = Color(value);
                                                  });
                                                });
                                              },
                                            ),
                                          ),
                                          TextButton(
                                            child: Text(
                                              i18n('Reset'),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                setS(() {
                                                  blurLayer.color = Colors.transparent;
                                                });
                                              });
                                            },
                                          ),
                                        ]),
                                        const SizedBox(height: 20.0),
                                        Text(
                                          i18n('Blur Radius'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
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
                                          TextButton(
                                            child: Text(
                                              i18n('Reset'),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            onPressed: () {
                                              setS(() {
                                                setState(() {
                                                  blurLayer.radius = 0.0;
                                                });
                                              });
                                            },
                                          ),
                                        ]),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          i18n('Color Opacity'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
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
                                          TextButton(
                                            child: Text(
                                              i18n('Reset'),
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            onPressed: () {
                                              setS(() {
                                                setState(() {
                                                  blurLayer.opacity = 0.0;
                                                });
                                              });
                                            },
                                          ),
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
                      icon: Icons.filter_vintage,
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
                        var layer = BackgroundLayerData(
                          file: ImageItem(filterAppliedImage),
                        );
                        layers.add(layer);
                        await layer.file.status;
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
    required this.icon, required this.text,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageAdjust extends StatefulWidget{
  final Uint8List image;

  const ImageAdjust({
    super.key,
    required this.image,
  });

  @override
  createState() => _ImageAdjustState();
}

class _ImageAdjustState extends State<ImageAdjust>{
  ScreenshotController screenshotController = ScreenshotController();

  Uint8List adjustedImage = Uint8List.fromList([]);

  @override
  Widget build(BuildContext context) {

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                var data = await screenshotController.capture();
                if (mounted) Navigator.pop(context, data);
              },
            ),
          ],
        ),
        body: Center(
          child: Screenshot(
            controller: screenshotController,
            child: Stack(
              children: [
                Image.memory(
                  widget.image,
                  fit: BoxFit.cover,
                ),
                /*ImageAdjustment(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(imageUrl),
                      ),
                    )
                  )
                )*/
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          alignment: Alignment.bottomCenter,
          height: 86 + MediaQuery.of(context).padding.bottom,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.rectangle,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  BottomButton(
                    icon: CupertinoIcons.brightness,
                    text: 'Brightness',
                    onTap: () async {
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
  createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  final GlobalKey<ExtendedImageEditorState> _controller = GlobalKey<ExtendedImageEditorState>();

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
    if (_controller.currentState != null) {
      // do nothing
    }

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            i18n('Crop'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
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
        body: Container(
          color: Colors.black,
          child: ExtendedImage.memory(
            widget.image,
            cacheRawData: true,
            fit: BoxFit.contain,
            extendedImageEditorKey: _controller,
            mode: ExtendedImageMode.editor,
            initEditorConfigHandler: (state) {

              return EditorConfig(
                cropAspectRatio: aspectRatio,
              );
            },
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
  createState() => _ImageFiltersState();
}

class _ImageFiltersState extends State<ImageFilters> {
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

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            i18n('Filters'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                var data = await screenshotController.capture();
                if (mounted) Navigator.pop(context, data);
              },
            ),
          ],
        ),
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
            height: 160,
            child: Column(children: [
              SizedBox(
                height: 40,
                child: selectedFilter == PresetFilters.none
                    ? Container()
                    : selectedFilter.build(
                  Slider(
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
              ),
              SizedBox(
                height: 120,
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
      ),
    );
  }

  Widget filterPreviewButton({required filter, required String name}) {

    return GestureDetector(
      onTap: () {
        selectedFilter = filter;
        setState(() {});
      },
      child: Column(children: [
        Container(
          height: 64,
          width: 64,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: FilterAppliedImage(
              image: widget.image,
              filter: filter,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          i18n(name),
          style: const TextStyle(fontSize: 12),
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

class ImageEditorDrawing extends StatefulWidget {
  final ImageItem image;

  const ImageEditorDrawing({
    super.key,
    required this.image,
  });

  @override
  State<ImageEditorDrawing> createState() => _ImageEditorDrawingState();
}

class _ImageEditorDrawingState extends State<ImageEditorDrawing> {
  Color pickerColor = Colors.white;
  Color currentColor = Colors.white;

  final control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  List<CubicPath> undoList = [];
  bool skipNextEvent = false;

  List<Color> colorList = [
    Colors.black,
    Colors.white,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.purple,
    Colors.brown,
    Colors.indigo,
    Colors.indigo,
  ];

  void changeColor(Color color) {
    currentColor = color;
    setState(() {});
  }

  @override
  void initState() {
    control.addListener(() {
      if (control.hasActivePath) return;

      if (skipNextEvent) {
        skipNextEvent = false;

        return;
      }

      undoList = [];
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.clear),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(
                Icons.undo,
                color: control.paths.isNotEmpty
                    ? Colors.white
                    : Colors.white.withAlpha(80),
              ),
              onPressed: () {
                if (control.paths.isEmpty) {
                  return;
                }
                skipNextEvent = true;
                undoList.add(control.paths.last);
                control.stepBack();
                setState(() {});
              },
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(
                Icons.redo,
                color: undoList.isNotEmpty
                    ? Colors.white
                    : Colors.white.withAlpha(80),
              ),
              onPressed: () {
                if (undoList.isEmpty) {

                  return;
                }
                control.paths.add(undoList.removeLast());
                setState(() {});
              },
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                if (control.paths.isEmpty) {
                  return Navigator.pop(context);
                }
                var data = await control.toImage(
                  color: currentColor,
                  height: widget.image.height,
                  width: widget.image.width,
                );
                if (!mounted) {

                  return;
                }

                return Navigator.pop(context, data!.buffer.asUint8List());
              },
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: currentColor == Colors.black ? Colors.white : Colors.black,
            image: DecorationImage(
              image: Image.memory(widget.image.image).image,
              fit: BoxFit.contain,
            ),
          ),
          child: HandSignature(
            control: control,
            color: currentColor,
            width: 1.0,
            maxWidth: 10.0,
            type: SignatureDrawType.shape,
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 80,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(blurRadius: 2),
              ],
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ColorButton(
                  color: Colors.yellow,
                  onTap: (color) {
                    showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      context: context,
                      builder: (context) {

                        return Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Container(
                              padding: const EdgeInsets.only(top: 16),
                              child: HueRingPicker(
                                pickerColor: pickerColor,
                                onColorChanged: changeColor,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                for (int i = 0; i < colorList.length; i++)
                  ColorButton(
                    color: colorList[i],
                    onTap: (color) => changeColor(color),
                    isSelected: colorList[i] == currentColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  final Color color;
  final Function onTap;
  final bool isSelected;

  const ColorButton({
    super.key,
    required this.color,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        onTap(color);
      },
      child: Container(
        height: 34,
        width: 34,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 23),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white54,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}