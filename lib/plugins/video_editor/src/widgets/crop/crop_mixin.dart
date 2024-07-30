import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../utilities/controller.dart';
import '../../models/transform_data.dart';
import '../../utilities/helpers.dart';
import '../viewer/cover_viewer.dart';
import '../../utilities/transform.dart';
import '../viewer/video_viewer.dart';

import 'crop_grid.dart';
import 'crop_grid_painter.dart';

mixin CropPreviewMixin<T extends StatefulWidget> on State<T> {
  final ValueNotifier<Rect> rect = ValueNotifier<Rect>(Rect.zero);
  final ValueNotifier<TransformData> transform =
      ValueNotifier<TransformData>(const TransformData());

  Size viewerSize = Size.zero;
  Size layout = Size.zero;

  @override
  void dispose() {
    transform.dispose();
    rect.dispose();
    super.dispose();
  }

  Size computeLayout(
    VideoEditorController controller, {
    EdgeInsets margin = EdgeInsets.zero,
    bool shouldFlipped = false,
  }) {
    if (viewerSize == Size.zero) return Size.zero;
    final videoRatio = controller.video.value.aspectRatio;
    final size = Size(viewerSize.width - margin.horizontal,
        viewerSize.height - margin.vertical);
    if (shouldFlipped) {
      return computeSizeWithRatio(videoRatio > 1 ? size.flipped : size,
              getOppositeRatio(videoRatio))
          .flipped;
    }

    return computeSizeWithRatio(size, videoRatio);
  }

  void updateRectFromBuild();

  Widget buildView(BuildContext context, TransformData transform);

  Widget buildVideoView(
    VideoEditorController controller,
    TransformData transform,
    CropBoundaries boundary, {
    bool showGrid = false,
  }) {
    return SizedBox.fromSize(
      size: layout,
      child: CropTransformWithAnimation(
        shouldAnimate: layout != Size.zero,
        transform: transform,
        child: VideoViewer(
          controller: controller,
          child: buildPaint(
            controller,
            boundary: boundary,
            showGrid: showGrid,
            showCenterRects: controller.preferredCropAspectRatio == null,
          ),
        ),
      ),
    );
  }

  Widget buildImageView(
    VideoEditorController controller,
    Uint8List bytes,
    TransformData transform,
  ) {
    return SizedBox.fromSize(
      size: layout,
      child: CropTransformWithAnimation(
        shouldAnimate: layout != Size.zero,
        transform: transform,
        child: CoverViewer(
          controller: controller,
          bytes: bytes,
          child:
              buildPaint(controller, showGrid: false, showCenterRects: false),
        ),
      ),
    );
  }

  Widget buildPaint(
    VideoEditorController controller, {
    CropBoundaries? boundary,
    bool showGrid = false,
    bool showCenterRects = false,
  }) {
    return ValueListenableBuilder(
      valueListenable: rect,
      builder: (_, Rect value, __) => RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: CropGridPainter(
            value,
            style: controller.cropStyle,
            boundary: boundary,
            showGrid: showGrid,
            showCenterRects: showCenterRects,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final size = constraints.biggest;

      if (size != viewerSize) {
        viewerSize = constraints.biggest;
        updateRectFromBuild();
      }

      return ValueListenableBuilder(
        valueListenable: transform,
        builder: (_, TransformData transform, __) =>
            buildView(context, transform),
      );
    });
  }
}
