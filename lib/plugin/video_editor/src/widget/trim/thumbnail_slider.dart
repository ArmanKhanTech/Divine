import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../utility/controller.dart';
import '../../model/transform_data.dart';
import '../../utility/helpers.dart';
import '../../utility/thumbnails.dart';
import '../crop/crop_grid_painter.dart';
import '../viewer/cover_viewer.dart';
import '../../utility/transform.dart';

class ThumbnailSlider extends StatefulWidget {
  const ThumbnailSlider({
    super.key,
    required this.controller,
    this.height = 60,
  });

  final double height;

  final VideoEditorController controller;

  @override
  State<ThumbnailSlider> createState() => _ThumbnailSliderState();
}

class _ThumbnailSliderState extends State<ThumbnailSlider> {
  final ValueNotifier<Rect> rect = ValueNotifier<Rect>(Rect.zero);
  final ValueNotifier<TransformData> transform =
      ValueNotifier<TransformData>(const TransformData());

  double sliderWidth = 1.0;

  Size layout = Size.zero;
  late Size maxLayout = _calculateMaxLayout();

  int thumbnailsCount = 8;
  late int neededThumbnails = thumbnailsCount;

  late Stream<List<Uint8List>> stream = (() => _generateThumbnails())();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scaleRect);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scaleRect);
    transform.dispose();
    rect.dispose();
    super.dispose();
  }

  void _scaleRect() {
    rect.value = calculateCroppedRect(widget.controller, layout);
    maxLayout = _calculateMaxLayout();

    transform.value = TransformData.fromRect(
      rect.value,
      layout,
      maxLayout,
      widget.controller,
    );

    neededThumbnails = (sliderWidth ~/ maxLayout.width) + 1;
    if (neededThumbnails > thumbnailsCount) {
      thumbnailsCount = neededThumbnails;
      setState(() => stream = _generateThumbnails());
    }
  }

  Stream<List<Uint8List>> _generateThumbnails() => generateTrimThumbnails(
        widget.controller,
        quantity: thumbnailsCount,
      );

  Size _calculateMaxLayout() {
    final ratio = rect.value == Rect.zero
        ? widget.controller.video.value.aspectRatio
        : rect.value.size.aspectRatio;

    if (isNumberAlmost(ratio, 1)) return Size.square(widget.height);

    final size = Size(widget.height * ratio, widget.height);

    if (widget.controller.isRotated) {
      return Size(widget.height / ratio, widget.height);
    }

    return size;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, box) {
      sliderWidth = box.maxWidth;

      return StreamBuilder<List<Uint8List>>(
        stream: stream,
        builder: (_, snapshot) {
          final data = snapshot.data;

          return snapshot.hasData
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: neededThumbnails,
                  itemBuilder: (_, i) => ValueListenableBuilder<TransformData>(
                    valueListenable: transform,
                    builder: (_, transform, __) {
                      final index =
                          getBestIndex(neededThumbnails, data!.length, i);

                      return Stack(
                        children: [
                          buildSingleThumbnail(
                            data[0],
                            transform,
                            isPlaceholder: true,
                          ),
                          if (index < data.length)
                            buildSingleThumbnail(
                              data[index],
                              transform,
                              isPlaceholder: false,
                            ),
                        ],
                      );
                    },
                  ),
                )
              : const SizedBox();
        },
      );
    });
  }

  Widget buildSingleThumbnail(
    Uint8List bytes,
    TransformData transform, {
    required bool isPlaceholder,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(maxLayout),
      child: CropTransform(
        transform: transform,
        child: CoverViewer(
          controller: widget.controller,
          bytes: bytes,
          fadeIn: !isPlaceholder,
          child: LayoutBuilder(builder: (_, constraints) {
            final size = constraints.biggest;
            if (!isPlaceholder && layout != size) {
              layout = size;
              WidgetsBinding.instance.addPostFrameCallback((_) => _scaleRect());
            }

            return RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: CropGridPainter(
                  rect.value,
                  showGrid: false,
                  style: widget.controller.cropStyle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
