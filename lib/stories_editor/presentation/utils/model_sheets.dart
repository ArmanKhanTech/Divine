import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_gif_picker/modal_gif_picker.dart';
import 'package:provider/provider.dart';
import '../../domain/models/editable_item.dart';
import '../../domain/notifiers/control_notifier.dart';
import '../../domain/notifiers/draggable_widget_notifier.dart';
import '../../domain/notifiers/painting_notifier.dart';
import '../../domain/notifiers/text_editing_notifier.dart';
import '../../domain/services/save_as_image.dart';
import '../widgets/animated_on_tap_button.dart';
import 'constants/app_enum.dart';

Future createGiphyItem(
    {required BuildContext context, required giphyKey}) async {
  final editableItem = Provider.of<DraggableWidgetNotifier>(context, listen: false);
  editableItem.giphy = await ModalGifPicker.pickModalSheetGif(
    context: context,
    apiKey: giphyKey,
    rating: GiphyRating.r,
    sticker: true,
    backDropColor: Colors.black,
    crossAxisCount: 3,
    childAspectRatio: 1.2,
    topDragColor: Colors.white.withOpacity(0.2),
  );

  /// create item of type GIF
  if (editableItem.giphy != null) {
    editableItem.draggableWidget.add(EditableItem()
      ..type = ItemType.gif
      ..gif = editableItem.giphy!
      ..position = const Offset(0.0, 0.0));
  }
}

Future<bool> exitDialog({required context, required contentKey}) async {
  return (
      await
  showDialog(
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
          height: 280,
          color: Colors.pink.withOpacity(0.2),
          blur: 5,
          padding: const EdgeInsets.all(20),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Discard Edits?',
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
                  _resetDefaults(context: context);
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Discard',
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
                  color: Colors.white10,
                ),
              ),

              AnimatedOnTapButton(
                onTap: () async {
                  final paintingProvider = Provider.of<PaintingNotifier>(context, listen: false);
                  final widgetProvider = Provider.of<DraggableWidgetNotifier>(context,
                      listen: false);
                  if (paintingProvider.lines.isNotEmpty ||
                      widgetProvider.draggableWidget.isNotEmpty) {
                    /// save image
                    var response = await takePicture(
                        contentKey: contentKey,
                        context: context,
                        saveToGallery: true);
                    if (response) {
                      _dispose(
                          context: context, message: 'Successfully saved');
                    } else {
                      _dispose(context: context, message: 'Error');
                    }
                  } else {
                    _dispose(context: context, message: 'Draft Empty');
                  }
                },
                child: const Text(
                  'Save Draft',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 22,
                child: Divider(
                  color: Colors.white10,
                ),
              ),

              AnimatedOnTapButton(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  'Cancel',
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
    ),
  )) ??
      false;
}

_resetDefaults({required BuildContext context}) {
  final paintingProvider = Provider.of<PaintingNotifier>(context, listen: false);
  final widgetProvider = Provider.of<DraggableWidgetNotifier>(context, listen: false);
  final controlProvider = Provider.of<ControlNotifier>(context, listen: false);
  final editingProvider = Provider.of<TextEditingNotifier>(context, listen: false);
  paintingProvider.lines.clear();
  widgetProvider.draggableWidget.clear();
  widgetProvider.setDefaults();
  paintingProvider.resetDefaults();
  editingProvider.setDefaults();
  controlProvider.mediaPath = '';
}

_dispose({required context, required message}) {
  _resetDefaults(context: context);
  Fluttertoast.showToast(msg: message);
  Navigator.of(context).pop(true);
}