import 'package:flutter/material.dart';

class CoverSelectionStyle {
  const CoverSelectionStyle({
    this.selectedBorderColor = Colors.white,
    this.borderWidth = 2,
    this.borderRadius = 5.0,
  });

  final Color selectedBorderColor;

  final double borderWidth;
  final double borderRadius;
}
