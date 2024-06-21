import 'package:divine/stories/stories_editor/presentation/main_view/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'domain/notifiers/control_notifier.dart';
import 'domain/notifiers/draggable_widget_notifier.dart';
import 'domain/notifiers/gradient_notifier.dart';
import 'domain/notifiers/painting_notifier.dart';
import 'domain/notifiers/scroll_notifier.dart';
import 'domain/notifiers/text_editing_notifier.dart';

class StoriesEditor extends StatefulWidget {
  final List<String>? fontFamilyList;

  final bool? isCustomFontList;

  final String giphyKey;

  final List<List<Color>>? gradientColors;

  final Widget? middleBottomWidget;

  final Function(String)? onDone;

  final Widget? onDoneButtonStyle;

  final Future<bool>? onBackPress;

  final List<Color>? colorList;

  final Color? editorBackgroundColor;

  final int? galleryThumbnailQuality;

  const StoriesEditor(
      {Key? key,
      required this.giphyKey,
      required this.onDone,
      this.middleBottomWidget,
      this.colorList,
      this.gradientColors,
      this.fontFamilyList,
      this.isCustomFontList,
      this.onBackPress,
      this.onDoneButtonStyle,
      this.editorBackgroundColor,
      this.galleryThumbnailQuality})
      : super(key: key);

  @override
  State<StoriesEditor> createState() => _StoriesEditorState();
}

class _StoriesEditorState extends State<StoriesEditor> {
  @override
  void initState() {
    // Paint.enableDithering = true;
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();

        return false;
      },
      child: ScreenUtilInit(
        designSize: const Size(1080, 1920),
        builder: (_, __) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ControlNotifier()),
            ChangeNotifierProvider(create: (_) => ScrollNotifier()),
            ChangeNotifierProvider(create: (_) => DraggableWidgetNotifier()),
            ChangeNotifierProvider(create: (_) => GradientNotifier()),
            ChangeNotifierProvider(create: (_) => PaintingNotifier()),
            ChangeNotifierProvider(create: (_) => TextEditingNotifier()),
          ],
          child: MainView(
            giphyKey: widget.giphyKey,
            onDone: widget.onDone,
            fontFamilyList: widget.fontFamilyList,
            isCustomFontList: widget.isCustomFontList,
            middleBottomWidget: widget.middleBottomWidget,
            gradientColors: widget.gradientColors,
            colorList: widget.colorList,
            onDoneButtonStyle: widget.onDoneButtonStyle,
            onBackPress: widget.onBackPress,
            editorBackgroundColor: widget.editorBackgroundColor,
            galleryThumbnailQuality: widget.galleryThumbnailQuality,
          ),
        ),
      ),
    );
  }
}
