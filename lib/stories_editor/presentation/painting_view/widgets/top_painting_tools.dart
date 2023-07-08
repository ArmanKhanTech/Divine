import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../domain/notifiers/control_notifier.dart';
import '../../../domain/notifiers/painting_notifier.dart';
import '../../utils/constants/app_enum.dart';
import '../../widgets/tool_button.dart';

class TopPaintingTools extends StatefulWidget {
  const TopPaintingTools({Key? key}) : super(key: key);

  @override
  State<TopPaintingTools> createState() => _TopPaintingToolsState();
}

class _TopPaintingToolsState extends State<TopPaintingTools> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ControlNotifier, PaintingNotifier>(
      builder: (context, controlNotifier, paintingNotifier, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (paintingNotifier.lines.isNotEmpty)
                  ToolButton(
                    onTap: paintingNotifier.removeLast,
                    onLongPress: paintingNotifier.clearAll,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    backGroundColor: Colors.black12,
                    child: Transform.scale(
                        scale: 0.6,
                        child: const ImageIcon(
                          AssetImage('assets/icons/return.png'),
                          color: Colors.white,
                        )),
                  ),

                ToolButton(
                  onTap: () {
                    paintingNotifier.paintingType = PaintingType.pen;
                  },
                  colorBorder: paintingNotifier.paintingType == PaintingType.pen
                      ? Colors.black
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  backGroundColor:
                  paintingNotifier.paintingType == PaintingType.pen
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black12,
                  child: Transform.scale(
                      scale: 1.2,
                      child: ImageIcon(
                        const AssetImage('assets/icons/pen.png'),
                        color: paintingNotifier.paintingType == PaintingType.pen
                            ? Colors.black
                            : Colors.white,
                      )),
                ),

                ToolButton(
                  onTap: () {
                    paintingNotifier.paintingType = PaintingType.marker;
                  },
                  colorBorder:
                  paintingNotifier.paintingType == PaintingType.marker
                      ? Colors.black
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  backGroundColor:
                  paintingNotifier.paintingType == PaintingType.marker
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black12,
                  child: Transform.scale(
                      scale: 1.2,
                      child: ImageIcon(
                        const AssetImage('assets/icons/marker.png'),
                        color:
                        paintingNotifier.paintingType == PaintingType.marker
                            ? Colors.black
                            : Colors.white,
                      )),
                ),

                ToolButton(
                  onTap: () {
                    paintingNotifier.paintingType = PaintingType.neon;
                  },
                  colorBorder:
                  paintingNotifier.paintingType == PaintingType.neon
                      ? Colors.black
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  backGroundColor:
                  paintingNotifier.paintingType == PaintingType.neon
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black12,
                  child: Transform.scale(
                      scale: 1.1,
                      child: ImageIcon(
                        const AssetImage('assets/icons/neon.png'),
                        color:
                        paintingNotifier.paintingType == PaintingType.neon
                            ? Colors.black
                            : Colors.white,
                      )),
                ),

                ToolButton(
                  onTap: () {
                    controlNotifier.isPainting = !controlNotifier.isPainting;
                    paintingNotifier.resetDefaults();
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  backGroundColor: Colors.black12,
                  child: Transform.scale(
                      scale: 0.7,
                      child: const ImageIcon(
                        AssetImage('assets/icons/check.png'),
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}