import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import '../../presentation/utils/constants/app_enum.dart';

class PaintingModel {
  List<Point> points;

  double size = 10;

  double thinning = 1;

  double smoothing = 1;

  bool isComplete = false;

  Color lineColor = Colors.black;

  double streamline;

  final bool simulatePressure;

  PaintingType paintingType = PaintingType.pen;

  PaintingModel(
      this.points,
      this.size,
      this.thinning,
      this.smoothing,
      this.isComplete,
      this.lineColor,
      this.streamline,
      this.simulatePressure,
      this.paintingType);
}