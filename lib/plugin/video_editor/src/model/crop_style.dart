import 'package:flutter/material.dart';
import '../utility/helpers.dart';

class CropGridStyle {
  const CropGridStyle({
    this.croppingBackground = Colors.black45,
    this.background = Colors.black,
    this.gridLineColor = Colors.white,
    this.gridLineWidth = 1,
    this.gridSize = 3,
    this.boundariesColor = Colors.white,
    this.selectedBoundariesColor = kDefaultSelectedColor,
    this.boundariesLength = 20,
    this.boundariesWidth = 5,
  });

  final Color croppingBackground;
  final Color background;

  final double gridLineWidth;

  final Color gridLineColor;

  final int gridSize;

  final Color boundariesColor;
  final Color selectedBoundariesColor;

  final double boundariesLength;
  final double boundariesWidth;
}
