import 'dart:async';
import 'dart:io';

import 'package:divine/plugin/story_editor/presentation/painting_view/widgets/sketcher.dart';
import 'package:divine/plugin/story_editor/presentation/painting_view/widgets/top_painting_tools.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../../domain/models/painting_model.dart';
import '../../domain/notifiers/control_notifier.dart';
import '../../domain/notifiers/painting_notifier.dart';
import '../widgets/color_selector.dart';
import '../widgets/size_slider_widget.dart';

class Painting extends StatefulWidget {
  const Painting({Key? key}) : super(key: key);

  @override
  State<Painting> createState() => _PaintingState();
}

class _PaintingState extends State<Painting> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<PaintingNotifier>(context, listen: false)
        ..linesStreamController =
            StreamController<List<PaintingModel>>.broadcast()
        ..currentLineStreamController =
            StreamController<PaintingModel>.broadcast();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PaintingModel? line;

    var screenSize = MediaQueryData.fromView(WidgetsBinding.instance.window);

    void onPanStart(DragStartDetails details, PaintingNotifier paintingNotifier,
        ControlNotifier controlProvider) {
      final box = context.findRenderObject() as RenderBox;
      final offset = box.globalToLocal(details.globalPosition);
      final point = Point(offset.dx, offset.dy);
      final points = [point];

      if (point.y >= 4 &&
          point.y <=
              (Platform.isIOS
                  ? (screenSize.size.height - 132) - screenSize.viewPadding.top
                  : screenSize.size.height - 132)) {
        line = PaintingModel(
            points,
            paintingNotifier.lineWidth,
            1,
            1,
            false,
            controlProvider.colorList![paintingNotifier.lineColor],
            1,
            true,
            paintingNotifier.paintingType);
      }
    }

    void onPanUpdate(DragUpdateDetails details,
        PaintingNotifier paintingNotifier, ControlNotifier controlNotifier) {
      final box = context.findRenderObject() as RenderBox;
      final offset = box.globalToLocal(details.globalPosition);
      final point = Point(offset.dx, offset.dy);
      final points = [...line!.points, point];

      if (point.y >= 6 &&
          point.y <=
              (Platform.isIOS
                  ? (screenSize.size.height - 132) - screenSize.viewPadding.top
                  : screenSize.size.height - 132)) {
        line = PaintingModel(
            points,
            paintingNotifier.lineWidth,
            1,
            1,
            false,
            controlNotifier.colorList![paintingNotifier.lineColor],
            1,
            true,
            paintingNotifier.paintingType);
        paintingNotifier.currentLineStreamController.add(line!);
      }
    }

    void onPanEnd(DragEndDetails details, PaintingNotifier paintingNotifier) {
      paintingNotifier.lines = List.from(paintingNotifier.lines)..add(line!);
      line = null;
      paintingNotifier.linesStreamController.add(paintingNotifier.lines);
    }

    Widget renderCurrentLine(BuildContext context,
        PaintingNotifier paintingNotifier, ControlNotifier controlNotifier) {
      return GestureDetector(
        onPanStart: (details) {
          onPanStart(details, paintingNotifier, controlNotifier);
        },
        onPanUpdate: (details) {
          onPanUpdate(details, paintingNotifier, controlNotifier);
        },
        onPanEnd: (details) {
          onPanEnd(details, paintingNotifier);
        },
        child: RepaintBoundary(
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: Platform.isIOS
                      ? (screenSize.size.height - 132) -
                          screenSize.viewPadding.top
                      : MediaQuery.of(context).size.height - 132,
                  child: StreamBuilder<PaintingModel>(
                      stream:
                          paintingNotifier.currentLineStreamController.stream,
                      builder: (context, snapshot) {
                        return CustomPaint(
                          painter: Sketcher(
                            lines: line == null ? [] : [line!],
                          ),
                        );
                      })),
            ),
          ),
        ),
      );
    }

    return Consumer2<ControlNotifier, PaintingNotifier>(
      builder: (context, controlNotifier, paintingNotifier, child) {
        return PopScope(
          onPopInvoked: (onPopInvoked) async {
            if (onPopInvoked) {
              controlNotifier.isPainting = false;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                paintingNotifier.closeConnection();
              });
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                renderCurrentLine(context, paintingNotifier, controlNotifier),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 140, left: 10),
                    child: SizeSliderWidget(),
                  ),
                ),
                const SafeArea(child: TopPaintingTools()),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 30.h, horizontal: 30.w),
                    child: const ColorSelector(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
