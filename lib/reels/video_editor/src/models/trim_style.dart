import 'package:flutter/material.dart';

enum TrimSliderEdgesType { bar, circle }

class TrimSliderStyle {
  const TrimSliderStyle({
    this.background = Colors.black,
    this.positionLineColor = Colors.blue,
    this.positionLineWidth = 5,
    this.lineColor = Colors.white,
    this.onTrimmingColor = Colors.white,
    this.onTrimmedColor = Colors.white,
    this.lineWidth = 2,
    this.borderRadius = 10.0,
    this.edgesType = TrimSliderEdgesType.bar,
    double? edgesSize,
    this.iconColor = Colors.black,
    this.iconSize = 15,
    this.leftIcon = Icons.arrow_back_ios_rounded,
    this.rightIcon = Icons.arrow_forward_ios_rounded,
  }) : edgesSize = edgesSize ?? (edgesType == TrimSliderEdgesType.bar ? 10 : 8);

  final Color background;
  final Color positionLineColor;

  final double positionLineWidth;

  final Color lineColor;
  final Color onTrimmingColor;
  final Color onTrimmedColor;

  final double lineWidth;
  final double borderRadius;

  final TrimSliderEdgesType edgesType;

  final double edgesSize;

  final Color iconColor;

  final double iconSize;

  final IconData? leftIcon;
  final IconData? rightIcon;

  double get edgeWidth => edgesType == TrimSliderEdgesType.bar ? edgesSize : lineWidth;
}
