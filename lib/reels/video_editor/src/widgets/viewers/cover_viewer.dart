import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../utilities/controller.dart';

class CoverViewer extends StatelessWidget {
  const CoverViewer({
    super.key,
    required this.controller,
    required this.bytes,
    this.child,
    this.fadeIn = true,
  });

  final VideoEditorController controller;

  final Uint8List bytes;

  final Widget? child;

  final bool fadeIn;

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: controller.video.value.aspectRatio,
            child: fadeIn ? FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 400),
                    image: MemoryImage(bytes),
                    placeholder: MemoryImage(kTransparentImage),
                  ) : Image.memory(
                    bytes,
                    color: const Color.fromRGBO(255, 255, 255, 0.2),
                    colorBlendMode: BlendMode.modulate,
                  ),
          ),
          if (child != null)
            AspectRatio(
              aspectRatio: controller.video.value.aspectRatio,
              child: child,
            ),
        ],
      ),
    );
  }
}
