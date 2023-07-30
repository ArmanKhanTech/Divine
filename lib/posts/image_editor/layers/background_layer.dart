import 'package:flutter/material.dart';
import '../data/layer.dart';

class BackgroundLayer extends StatefulWidget {
  final BackgroundLayerData layerData;
  final VoidCallback? onUpdate;

  const BackgroundLayer({
    super.key,
    required this.layerData,
    this.onUpdate,
  });

  @override
  State<BackgroundLayer> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends State<BackgroundLayer> {
  @override
  Widget build(BuildContext context) {

    return Container(
      width: widget.layerData.file.width.toDouble(),
      height: widget.layerData.file.height.toDouble(),
      padding: EdgeInsets.zero,
      child: Image.memory(widget.layerData.file.image),
    );
  }
}