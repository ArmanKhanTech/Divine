import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_media_picker/gallery_media_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import '../../domain/models/editable_item.dart';
import '../../domain/models/painting_model.dart';
import '../../domain/notifiers/control_notifier.dart';
import '../../domain/notifiers/draggable_widget_notifier.dart';
import '../../domain/notifiers/gradient_notifier.dart';
import '../../domain/notifiers/painting_notifier.dart';
import '../../domain/notifiers/scroll_notifier.dart';
import '../../domain/notifiers/text_editing_notifier.dart';
import '../bar_tools/bottom_tools.dart';
import '../bar_tools/top_tools.dart';
import '../draggable_items/delete_item.dart';
import '../draggable_items/draggable_widget.dart';
import '../painting_view/painting.dart';
import '../painting_view/widgets/sketcher.dart';
import '../text_editor_widget/text_editor.dart';
import '../utils/constants/app_enum.dart';
import '../utils/model_sheets.dart';
import '../widgets/animated_on_tap_button.dart';
import '../widgets/scrollable_page_view.dart';
import 'package:divine/widgets/progress_indicators.dart';

// ignore_for_file: must_be_immutable
class MainView extends StatefulWidget {
  final List<String>? fontFamilyList;

  final bool? isCustomFontList;

  final String giphyKey;

  final List<List<Color>>? gradientColors;

  final Widget? middleBottomWidget;

  final Function(String)? onDone;

  final Widget? onDoneButtonStyle;

  final Future<bool>? onBackPress;

  Color? editorBackgroundColor;

  final int? galleryThumbnailQuality;

  List<Color>? colorList;

  MainView(
      {Key? key,
        required this.giphyKey,
        required this.onDone,
        this.middleBottomWidget,
        this.colorList,
        this.isCustomFontList,
        this.fontFamilyList,
        this.gradientColors,
        this.onBackPress,
        this.onDoneButtonStyle,
        this.editorBackgroundColor,
        this.galleryThumbnailQuality})
      : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final GlobalKey contentKey = GlobalKey();

  EditableItem? _activeItem;

  Offset _initPos = const Offset(0, 0);
  Offset _currentPos = const Offset(0, 0);
  double _currentScale = 1;
  double _currentRotation = 0;

  bool _isDeletePosition = false;
  bool _inAction = false;
  bool _isLoading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var control = Provider.of<ControlNotifier>(context, listen: false);

      control.giphyKey = widget.giphyKey;
      control.middleBottomWidget = widget.middleBottomWidget;
      control.isCustomFontList = widget.isCustomFontList ?? false;
      if (widget.gradientColors != null) {
        control.gradientColors = widget.gradientColors;
      }
      if (widget.fontFamilyList != null) {
        control.fontList = widget.fontFamilyList;
      }
      if (widget.colorList != null) {
        control.colorList = widget.colorList;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();

    return WillPopScope(
      onWillPop: _popScope,
      child: LoadingOverlay(
        isLoading: _isLoading,
        color: Colors.black,
        progressIndicator: circularProgress(context, const Color(0XFF03A9F4)),
        opacity: 0.5,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(5.0),
            child: AppBar(
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.black,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: Colors.black,
                systemNavigationBarIconBrightness: Brightness.light,
                systemNavigationBarDividerColor: null,
              ),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.black,
            ),
          ),
          body: Material(
            color: widget.editorBackgroundColor == Colors.transparent
                ? Colors.black
                : widget.editorBackgroundColor ?? Colors.black,
            child: Consumer6<
                ControlNotifier,
                DraggableWidgetNotifier,
                ScrollNotifier,
                GradientNotifier,
                PaintingNotifier,
                TextEditingNotifier>(
              builder: (context, controlNotifier, itemProvider, scrollProvider,
                  colorProvider, paintingProvider, editingProvider, child) {
                return SafeArea(
                  child: ScrollablePageView(
                    scrollPhysics: controlNotifier.mediaPath.isEmpty &&
                        itemProvider.draggableWidget.isEmpty &&
                        !controlNotifier.isPainting &&
                        !controlNotifier.isTextEditing,
                    pageController: scrollProvider.pageController,
                    gridController: scrollProvider.gridController,
                    mainView: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              GestureDetector(
                                onScaleStart: _onScaleStart,
                                onScaleUpdate: _onScaleUpdate,
                                onTap: () {
                                  controlNotifier.isTextEditing =
                                  !controlNotifier.isTextEditing;
                                },
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: SizedBox(
                                      width: screenUtil.screenWidth,
                                      child: RepaintBoundary(
                                        key: contentKey,
                                        child: AnimatedContainer(
                                          duration:
                                          const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                              gradient: controlNotifier
                                                  .mediaPath.isEmpty
                                                  ? LinearGradient(
                                                colors: controlNotifier
                                                    .gradientColors![
                                                controlNotifier
                                                    .gradientIndex],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                                  : LinearGradient(
                                                colors: [
                                                  colorProvider.color1,
                                                  colorProvider.color2
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              )),
                                          child: GestureDetector(
                                            onScaleStart: _onScaleStart,
                                            onScaleUpdate: _onScaleUpdate,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                PhotoView.customChild(
                                                  backgroundDecoration:
                                                  const BoxDecoration(
                                                      color:
                                                      Colors.transparent),
                                                  child: Container(),
                                                ),
                                                ...itemProvider.draggableWidget
                                                    .map((editableItem) {
                                                  return DraggableWidget(
                                                    context: context,
                                                    draggableWidget: editableItem,
                                                    onPointerDown: (details) {
                                                      _updateItemPosition(
                                                        editableItem,
                                                        details,
                                                      );
                                                    },
                                                    onPointerUp: (details) {
                                                      _deleteItemOnCoordinates(
                                                        editableItem,
                                                        details,
                                                      );
                                                    },
                                                    onPointerMove: (details) {
                                                      _deletePosition(
                                                        editableItem,
                                                        details,
                                                      );
                                                    },
                                                  );
                                                }),

                                                IgnorePointer(
                                                  ignoring: true,
                                                  child: Align(
                                                    alignment: Alignment.topCenter,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                      ),
                                                      child: RepaintBoundary(
                                                        child: SizedBox(
                                                          width: screenUtil
                                                              .screenWidth,
                                                          child: StreamBuilder<
                                                              List<PaintingModel>>(
                                                            stream: paintingProvider
                                                                .linesStreamController
                                                                .stream,
                                                            builder: (context,
                                                                snapshot) {
                                                              return CustomPaint(
                                                                painter: Sketcher(
                                                                  lines:
                                                                  paintingProvider
                                                                      .lines,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              if (itemProvider.draggableWidget.isEmpty &&
                                  !controlNotifier.isTextEditing &&
                                  paintingProvider.lines.isEmpty)
                                IgnorePointer(
                                  ignoring: true,
                                  child: Center(
                                    child: Text('Tap to type',
                                        style: TextStyle(
                                            fontFamily: 'Alegreya',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 30,
                                            color: Colors.white.withOpacity(0.5),
                                            shadows: <Shadow>[
                                              Shadow(
                                                  offset: const Offset(1.0, 1.0),
                                                  blurRadius: 3.0,
                                                  color: Colors.black45
                                                      .withOpacity(0.3))
                                            ]
                                        )
                                    ),
                                  ),
                                ),

                              Visibility(
                                visible: !controlNotifier.isTextEditing &&
                                    !controlNotifier.isPainting,
                                child: Align(
                                    alignment: Alignment.topCenter,
                                    child: TopTools(
                                      contentKey: contentKey,
                                      context: context,
                                      onDone: (path) {
                                        setState(() {
                                          controlNotifier.mediaPath = path.toString();
                                          if (controlNotifier.mediaPath.isNotEmpty) {
                                            itemProvider.draggableWidget.insert(
                                                0,
                                                EditableItem()
                                                  ..type = ItemType.image
                                                  ..position = const Offset(0.0, 0));
                                          }
                                        });
                                      },
                                    )
                                ),
                              ),

                              DeleteItem(
                                activeItem: _activeItem,
                                animationsDuration:
                                const Duration(milliseconds: 300),
                                isDeletePosition: _isDeletePosition,
                              ),

                              Visibility(
                                visible: controlNotifier.isTextEditing,
                                child: TextEditor(
                                  context: context,
                                ),
                              ),

                              Visibility(
                                visible: controlNotifier.isPainting,
                                child: const Painting(),
                              ),
                            ],
                          ),
                        ),

                        if (!kIsWeb)
                          BottomTools(
                            contentKey: contentKey,
                            onDone: (bytes) {
                              setState(() {
                                widget.onDone!(bytes);
                              });
                            },
                            onTapped : (isLoading) {
                              setState(() {
                              _isLoading = isLoading;
                              });
                            },
                            onDoneButtonStyle: widget.onDoneButtonStyle,
                            editorBackgroundColor: widget.editorBackgroundColor,
                          ),
                      ],
                    ),
                    gallery: GalleryMediaPicker(
                      mediaPickerParams: MediaPickerParamsModel(
                        gridViewController: scrollProvider.gridController,
                        thumbnailQuality: 200,
                        singlePick: false,
                        onlyImages: true,
                        appBarColor: widget.editorBackgroundColor ?? Colors.black,
                        gridViewPhysics: itemProvider.draggableWidget.isEmpty
                            ? const NeverScrollableScrollPhysics()
                            : const ScrollPhysics(),
                        appBarLeadingWidget: Padding(
                          padding: const EdgeInsets.only(bottom: 15, right: 15),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: AnimatedOnTapButton(
                              onTap: () {
                                scrollProvider.pageController.animateToPage(0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.2,
                                    )),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      pathList: (path) {
                        final file = File(path.first.path.toString());
                        int sizeInBytes = file.lengthSync();
                        double sizeInMb = sizeInBytes / (1024 * 1024);
                        if (sizeInMb > 2){
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File size is too large ( > 2 MB)', textAlign: TextAlign.center, style: TextStyle(fontSize: 15),), backgroundColor: Colors.blue,
                              behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2), padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                              )
                            )
                          );
                        } else{
                          controlNotifier.mediaPath = path.first.path.toString();
                          if (controlNotifier.mediaPath.isNotEmpty) {
                            itemProvider.draggableWidget.insert(
                                0,
                                EditableItem()
                                  ..type = ItemType.image
                                  ..position = const Offset(0.0, 0));
                          }
                          scrollProvider.pageController.animateToPage(0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      )
    );
  }

  Future<bool> _popScope() async {
    final controlNotifier =
    Provider.of<ControlNotifier>(context, listen: false);

    if (controlNotifier.isTextEditing) {
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
      return false;
    }

    else if (controlNotifier.isPainting) {
      controlNotifier.isPainting = !controlNotifier.isPainting;
      return false;
    }

    else if (!controlNotifier.isTextEditing && !controlNotifier.isPainting) {
      return widget.onBackPress ??
          exitDialog(context: context, contentKey: contentKey);
    }
    return false;
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_activeItem == null) {
      return;
    }
    _initPos = details.focalPoint;
    _currentPos = _activeItem!.position;
    _currentScale = _activeItem!.scale;
    _currentRotation = _activeItem!.rotation;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final ScreenUtil screenUtil = ScreenUtil();
    if (_activeItem == null) {
      return;
    }
    final delta = details.focalPoint - _initPos;

    final left = (delta.dx / screenUtil.screenWidth) + _currentPos.dx;
    final top = (delta.dy / screenUtil.screenHeight) + _currentPos.dy;

    setState(() {
      _activeItem!.position = Offset(left, top);
      _activeItem!.rotation = details.rotation + _currentRotation;
      _activeItem!.scale = details.scale * _currentScale;
    });
  }

  void _deletePosition(EditableItem item, PointerMoveEvent details) {
    if (item.type == ItemType.text &&
        item.position.dy >= 0.75.h &&
        item.position.dx >= -0.4.w &&
        item.position.dx <= 0.2.w) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else if (item.type == ItemType.gif &&
        item.position.dy >= 0.62.h &&
        item.position.dx >= -0.35.w &&
        item.position.dx <= 0.15) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else {
      setState(() {
        _isDeletePosition = false;
        item.deletePosition = false;
      });
    }
  }

  void _deleteItemOnCoordinates(EditableItem item, PointerUpEvent details) {
    var itemProvider = Provider.of<DraggableWidgetNotifier>(context, listen: false)
            .draggableWidget;
    _inAction = false;
    if (item.type == ItemType.image) {
    } else if (item.type == ItemType.text &&
        item.position.dy >= 0.75.h &&
        item.position.dx >= -0.4.w &&
        item.position.dx <= 0.2.w ||
        item.type == ItemType.gif &&
            item.position.dy >= 0.62.h &&
            item.position.dx >= -0.35.w &&
            item.position.dx <= 0.15) {
      setState(() {
        itemProvider.removeAt(itemProvider.indexOf(item));
        HapticFeedback.heavyImpact();
      });
    } else {
      setState(() {
        _activeItem = null;
      });
    }
    setState(() {
      _activeItem = null;
    });
  }

  void _updateItemPosition(EditableItem item, PointerDownEvent details) {
    if (_inAction) {
      return;
    }

    _inAction = true;
    _activeItem = item;
    _initPos = details.position;
    _currentPos = item.position;
    _currentScale = item.scale;
    _currentRotation = item.rotation;

    HapticFeedback.lightImpact();
  }
}