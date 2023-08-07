import 'dart:math';
import 'package:flutter/material.dart';
import '../../controller.dart';
import '../../models/transform_data.dart';
import '../../utilities/helpers.dart';
import 'crop_mixin.dart';

@protected
enum CropBoundaries {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  inside,
  topCenter,
  centerRight,
  centerLeft,
  bottomCenter,
  none
}

class CropGridViewer extends StatefulWidget {
  const CropGridViewer.preview({
    super.key,
    required this.controller,
  })  : showGrid = false,
        rotateCropArea = true,
        margin = EdgeInsets.zero;

  const CropGridViewer.edit({
    super.key,
    required this.controller,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
    this.rotateCropArea = true,
  }) : showGrid = true;

  final VideoEditorController controller;

  final bool showGrid;

  final EdgeInsets margin;

  final bool rotateCropArea;

  @override
  State<CropGridViewer> createState() => _CropGridViewerState();
}

class _CropGridViewerState extends State<CropGridViewer> with CropPreviewMixin {
  CropBoundaries boundary = CropBoundaries.none;

  late VideoEditorController controller;

  late final double minRectSize = controller.cropStyle.boundariesLength * 2;

  @override
  void initState() {
    controller = widget.controller;
    controller.addListener(widget.showGrid ? updateRect : scaleRect);
    if (widget.showGrid) {
      controller.cacheMaxCrop = controller.maxCrop;
      controller.cacheMinCrop = controller.minCrop;
    }

    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(widget.showGrid ? updateRect : scaleRect);
    super.dispose();
  }

  double? get aspectRatio => widget.rotateCropArea == false &&
          controller.isRotated &&
          controller.preferredCropAspectRatio != null
      ? getOppositeRatio(controller.preferredCropAspectRatio!)
      : controller.preferredCropAspectRatio;

  Size _computeLayout() => computeLayout(
        controller,
        margin: widget.margin,
        shouldFlipped: controller.isRotated && widget.showGrid,
      );

  void updateRect() {
    layout = _computeLayout();
    transform.value = TransformData.fromController(controller);
    calculatePrefferedCrop();
  }

  void calculatePrefferedCrop() {
    Rect newRect = calculateCroppedRect(
      controller,
      layout,
      min: controller.cacheMinCrop,
      max: controller.cacheMaxCrop,
    );
    if (controller.preferredCropAspectRatio != null) {
      newRect = resizeCropToRatio(
        layout,
        newRect,
        widget.rotateCropArea == false && controller.isRotated
            ? getOppositeRatio(controller.preferredCropAspectRatio!)
            : controller.preferredCropAspectRatio!,
      );
    }

    setState(() {
      rect.value = newRect;
      onPanEnd(force: true);
    });
  }

  void scaleRect() {
    layout = _computeLayout();
    rect.value = calculateCroppedRect(controller, layout);
    transform.value =
        TransformData.fromRect(rect.value, layout, viewerSize, controller);
  }

  Rect expandedRect() {
    final expandedPosition = _expandedPosition(rect.value.center);
    return Rect.fromCenter(
        center: rect.value.center,
        width: rect.value.width + expandedPosition.width,
        height: rect.value.height + expandedPosition.height);
  }

  Rect _expandedPosition(Offset position) => Rect.fromCenter(center: position, width: 48, height: 48);

  Offset get gestureOffset => Offset(
        (viewerSize.width / 2) - (layout.width / 2),
        (viewerSize.height / 2) - (layout.height / 2),
      );

  void _onPanDown(DragDownDetails details) {
    final Offset pos = details.localPosition - gestureOffset;
    boundary = CropBoundaries.none;

    if (expandedRect().contains(pos)) {
      boundary = CropBoundaries.inside;

      if (_expandedPosition(rect.value.topLeft).contains(pos)) {
        boundary = CropBoundaries.topLeft;
      } else if (_expandedPosition(rect.value.topRight).contains(pos)) {
        boundary = CropBoundaries.topRight;
      } else if (_expandedPosition(rect.value.bottomRight).contains(pos)) {
        boundary = CropBoundaries.bottomRight;
      } else if (_expandedPosition(rect.value.bottomLeft).contains(pos)) {
        boundary = CropBoundaries.bottomLeft;
      } else if (controller.preferredCropAspectRatio == null) {
        if (_expandedPosition(rect.value.centerLeft).contains(pos)) {
          boundary = CropBoundaries.centerLeft;
        } else if (_expandedPosition(rect.value.topCenter).contains(pos)) {
          boundary = CropBoundaries.topCenter;
        } else if (_expandedPosition(rect.value.centerRight).contains(pos)) {
          boundary = CropBoundaries.centerRight;
        } else if (_expandedPosition(rect.value.bottomCenter).contains(pos)) {
          boundary = CropBoundaries.bottomCenter;
        }
      }
      setState(() {});
      controller.isCropping = true;
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (boundary == CropBoundaries.none) return;
    final Offset delta = details.delta;

    switch (boundary) {
      case CropBoundaries.inside:
        final Offset pos = rect.value.topLeft + delta;
        rect.value = Rect.fromLTWH(
            pos.dx.clamp(0, layout.width - rect.value.width),
            pos.dy.clamp(0, layout.height - rect.value.height),
            rect.value.width,
            rect.value.height);
        break;
      case CropBoundaries.topLeft:
        final Offset pos = rect.value.topLeft + delta;
        changeRect(left: pos.dx, top: pos.dy);
        break;
      case CropBoundaries.topRight:
        final Offset pos = rect.value.topRight + delta;
        changeRect(right: pos.dx, top: pos.dy);
        break;
      case CropBoundaries.bottomRight:
        final Offset pos = rect.value.bottomRight + delta;
        changeRect(right: pos.dx, bottom: pos.dy);
        break;
      case CropBoundaries.bottomLeft:
        final Offset pos = rect.value.bottomLeft + delta;
        changeRect(left: pos.dx, bottom: pos.dy);
        break;
      case CropBoundaries.topCenter:
        changeRect(top: rect.value.top + delta.dy);
        break;
      case CropBoundaries.bottomCenter:
        changeRect(bottom: rect.value.bottom + delta.dy);
        break;
      case CropBoundaries.centerLeft:
        changeRect(left: rect.value.left + delta.dx);
        break;
      case CropBoundaries.centerRight:
        changeRect(right: rect.value.right + delta.dx);
        break;
      case CropBoundaries.none:
        break;
    }
  }

  void onPanEnd({bool force = false}) {
    if (boundary != CropBoundaries.none || force) {
      final Rect r = rect.value;
      controller.cacheMinCrop = Offset(
        r.left / layout.width,
        r.top / layout.height,
      );
      controller.cacheMaxCrop = Offset(
        r.right / layout.width,
        r.bottom / layout.height,
      );
      controller.isCropping = false;
      setState(() => boundary = CropBoundaries.none);
    }
  }

  void changeRect({double? left, double? top, double? right, double? bottom}) {
    top = max(0, top ?? rect.value.top);
    left = max(0, left ?? rect.value.left);
    right = min(layout.width, right ?? rect.value.right);
    bottom = min(layout.height, bottom ?? rect.value.bottom);

    if (aspectRatio != null) {
      final width = right - left;
      final height = bottom - top;

      if (width / height > aspectRatio!) {
        switch (boundary) {
          case CropBoundaries.topLeft:
          case CropBoundaries.bottomLeft:
            left = right - height * aspectRatio!;
            break;
          case CropBoundaries.topRight:
          case CropBoundaries.bottomRight:
            right = left + height * aspectRatio!;
            break;
          default:
            assert(false);
        }
      } else {
        switch (boundary) {
          case CropBoundaries.topLeft:
          case CropBoundaries.topRight:
            top = bottom - width / aspectRatio!;
            break;
          case CropBoundaries.bottomLeft:
          case CropBoundaries.bottomRight:
            bottom = top + width / aspectRatio!;
            break;
          default:
            assert(false);
        }
      }
    }

    final newRect = Rect.fromLTRB(left, top, right, bottom);

    if (newRect.width < minRectSize ||
        newRect.height < minRectSize ||
        !isRectContained(layout, newRect)) return;

    rect.value = newRect;
  }

  @override
  void updateRectFromBuild() {
    if (widget.showGrid) {
      WidgetsBinding.instance.addPostFrameCallback((_) => updateRect());
    } else {
      scaleRect();
    }
  }

  @override
  Widget buildView(BuildContext context, TransformData transform) {
    if (widget.showGrid == false) {

      return buildCropView(transform);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        buildCropView(transform),

        Transform.rotate(
          angle: transform.rotation,
          child: GestureDetector(
            onPanDown: _onPanDown,
            onPanUpdate: onPanUpdate,
            onPanEnd: (_) => onPanEnd(),
            onTapUp: (_) => onPanEnd(),
            child: const SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    // color: Colors.redAccent.withOpacity(0.4), // dev only
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCropView(TransformData transform) {
    return Padding(
      padding: widget.margin,
      child: buildVideoView(
        controller,
        transform,
        boundary,
        showGrid: widget.showGrid,
      ),
    );
  }
}
