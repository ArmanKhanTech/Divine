import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../domain/notifiers/control_notifier.dart';
import '../../domain/notifiers/draggable_widget_notifier.dart';
import '../../domain/notifiers/painting_notifier.dart';
import '../../domain/services/save_as_image.dart';
import '../utils/model_sheets.dart';
import '../widgets/animated_on_tap_button.dart';
import '../widgets/tool_button.dart';

class TopTools extends StatefulWidget {
  final GlobalKey contentKey;
  final BuildContext context;
  const TopTools({Key? key, required this.contentKey, required this.context})
      : super(key: key);

  @override
  State<TopTools> createState() => _TopToolsState();
}

class _TopToolsState extends State<TopTools> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<ControlNotifier, PaintingNotifier,
        DraggableWidgetNotifier>(
      builder: (_, controlNotifier, paintingNotifier, itemNotifier, __) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.w),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ToolButton(
                    backGroundColor: Colors.black12,
                    onTap: () async {
                      var res = await exitDialog(
                          context: widget.context,
                          contentKey: widget.contentKey);
                      if (res) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    )),
                if (controlNotifier.mediaPath.isEmpty)
                  _selectColor(
                      controlProvider: controlNotifier,
                      onTap: () {
                        if (controlNotifier.gradientIndex >=
                            controlNotifier.gradientColors!.length - 1) {
                          setState(() {
                            controlNotifier.gradientIndex = 0;
                          });
                        } else {
                          setState(() {
                            controlNotifier.gradientIndex += 1;
                          });
                        }
                      }),
                ToolButton(
                    backGroundColor: Colors.black12,
                    onTap: () async {
                      if (paintingNotifier.lines.isNotEmpty ||
                          itemNotifier.draggableWidget.isNotEmpty) {
                        var response = await takePicture(
                            contentKey: widget.contentKey,
                            context: context,
                            saveToGallery: true);
                        if (response) {
                          Fluttertoast.showToast(msg: 'Successfully saved');
                        } else {
                          Fluttertoast.showToast(msg: 'Error');
                        }
                      }
                    },
                    child: const ImageIcon(
                      AssetImage('assets/icons/download.png'),
                      color: Colors.white,
                      size: 20,
                    )),
                ToolButton(
                    backGroundColor: Colors.black12,
                    onTap: () => createGiphyItem(
                        context: context, giphyKey: controlNotifier.giphyKey),
                    child: const ImageIcon(
                      AssetImage('assets/icons/stickers.png'),
                      color: Colors.white,
                      size: 20,
                    )),
                ToolButton(
                    backGroundColor: Colors.black12,
                    onTap: () {
                      controlNotifier.isPainting = true;
                    },
                    child: const ImageIcon(
                      AssetImage('assets/icons/draw.png'),
                      color: Colors.white,
                      size: 20,
                    )),
                ToolButton(
                  backGroundColor: Colors.black12,
                  onTap: () => controlNotifier.isTextEditing =
                  !controlNotifier.isTextEditing,
                  child: const ImageIcon(
                    AssetImage('assets/icons/text.png'),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _selectColor({onTap, controlProvider}) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 8),
      child: AnimatedOnTapButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: controlProvider
                      .gradientColors![controlProvider.gradientIndex]),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}