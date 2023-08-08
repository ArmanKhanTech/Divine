import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../controller.dart';

const kDefaultSelectedColor = Color(0xffffcc00);

Size computeSizeWithRatio(Size layout, double r) {
  if (layout.aspectRatio == r) {

    return layout;
  }

  if (layout.aspectRatio > r) {

    return Size(layout.height * r, layout.height);
  }

  if (layout.aspectRatio < r) {

    return Size(layout.width, layout.width / r);
  }

  assert(false, 'An error occurred while computing the aspectRatio');

  return Size.zero;
}

Rect resizeCropToRatio(Size layout, Rect crop, double r) {
  if (r < crop.size.aspectRatio) {
    final maxSide = min(crop.longestSide, layout.shortestSide);
    final size = Size(maxSide, maxSide / r);

    final rect = Rect.fromCenter(
      center: crop.center,
      width: size.width,
      height: size.height,
    );

    if (rect.size <= layout) return translateRectIntoBounds(layout, rect);
  }

  final newCenteredCrop = computeSizeWithRatio(crop.size, r);
  final rect = Rect.fromCenter(
    center: crop.center,
    width: newCenteredCrop.width,
    height: newCenteredCrop.height,
  );

  return translateRectIntoBounds(layout, rect);
}

Rect translateRectIntoBounds(Size layout, Rect rect) {
  final double translateX = (rect.left < 0 ? rect.left.abs() : 0) +
      (rect.right > layout.width ? layout.width - rect.right : 0);
  final double translateY = (rect.top < 0 ? rect.top.abs() : 0) +
      (rect.bottom > layout.height ? layout.height - rect.bottom : 0);

  if (translateX != 0 || translateY != 0) {

    return rect.translate(translateX, translateY);
  }

  return rect;
}

double scaleToSize(Size layout, Rect rect) =>
    min(layout.width / rect.width, layout.height / rect.height);

double scaleToSizeMax(Size layout, Rect rect) =>
    max(layout.width / rect.width, layout.height / rect.height);

Rect calculateCroppedRect(
  VideoEditorController controller,
  Size layout, {
  Offset? min,
  Offset? max,
}) {
  final Offset minCrop = min ?? controller.minCrop;
  final Offset maxCrop = max ?? controller.maxCrop;

  return Rect.fromPoints(
    Offset(minCrop.dx * layout.width, minCrop.dy * layout.height),
    Offset(maxCrop.dx * layout.width, maxCrop.dy * layout.height),
  );
}

bool isNumberAlmost(double a, int b) => nearEqual(a, b.toDouble(), 0.01);

int getBestIndex(int max, int length, int index) =>
    max >= length || max == 0 ? index : 1 + (index * (length / max)).round();

bool isRectContained(Size size, Rect rect) =>
    rect.left >= 0 &&
    rect.top >= 0 &&
    rect.right <= size.width &&
    rect.bottom <= size.height;

double getOppositeRatio(double ratio) => 1 / ratio;
