import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/layer.dart';

class BackgroundBlurLayer extends StatefulWidget {
  final BackgroundBlurLayerData layerData;
  final VoidCallback? onUpdate;

  const BackgroundBlurLayer({
    super.key,
    required this.layerData,
    this.onUpdate,
  });

  @override
  State<BackgroundBlurLayer> createState() => _BackgroundBlurLayerState();
}

class _BackgroundBlurLayerState extends State<BackgroundBlurLayer> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.layerData.radius,
          sigmaY: widget.layerData.radius,
        ),
        blendMode: BlendMode.srcOver,
        child: Container(
          color: widget.layerData.color
              .withAlpha((widget.layerData.opacity * 100).toInt()),
        ),
      ),
    );
  }
}
