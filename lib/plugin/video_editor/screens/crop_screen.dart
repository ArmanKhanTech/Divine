import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import '../src/utilities/controller.dart';
import '../src/models/crop_style.dart';
import '../src/widgets/crop/crop_grid.dart';

class CropScreen extends StatelessWidget {
  const CropScreen({super.key, required this.controller});

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: IconButton(
                  onPressed: () =>
                      controller.rotate90Degrees(RotateDirection.left),
                  icon: const Icon(Icons.rotate_left, color: Colors.white, size: 30),
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () =>
                      controller.rotate90Degrees(RotateDirection.right),
                  icon: const Icon(Icons.rotate_right, color: Colors.white, size: 30),
                ),
              )
            ]),
            const SizedBox(height: 15),
            Expanded(
              child: CropGridViewer.edit(
                controller: controller,
                rotateCropArea: false,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                flex: 2,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 20),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () =>
                            controller.preferredCropAspectRatio = controller
                                .preferredCropAspectRatio
                                ?.toFraction()
                                .inverse()
                                .toDouble(),
                            icon: controller.preferredCropAspectRatio != null &&
                                controller.preferredCropAspectRatio! < 1
                                ? const Icon(
                                Icons.panorama_vertical_select_rounded, color: Colors.white)
                                : const Icon(Icons.panorama_vertical_rounded, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () =>
                            controller.preferredCropAspectRatio = controller
                                .preferredCropAspectRatio
                                ?.toFraction()
                                .inverse()
                                .toDouble(),
                            icon: controller.preferredCropAspectRatio != null &&
                                controller.preferredCropAspectRatio! > 1
                                ? const Icon(
                                Icons.panorama_horizontal_select_rounded, color: Colors.white, size: 30)
                                : const Icon(Icons.panorama_horizontal_rounded, color: Colors.white, size: 30),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildCropButton(context, null),
                          _buildCropButton(context, 1.toFraction()),
                          _buildCropButton(
                              context, Fraction.fromString("9/16")),
                          _buildCropButton(context, Fraction.fromString("3/4")),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: IconButton(
                  onPressed: () {
                    controller.applyCacheCrop();
                    Navigator.pop(context);
                  },
                  icon: Center(
                    child: Text(
                      "Done",
                      style: TextStyle(
                        color: const CropGridStyle().selectedBoundariesColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildCropButton(BuildContext context, Fraction? f) {
    if (controller.preferredCropAspectRatio != null &&
        controller.preferredCropAspectRatio! > 1) f = f?.inverse();

    return Flexible(
      child: TextButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: controller.preferredCropAspectRatio == f?.toDouble()
              ? Colors.grey.shade800
              : null,
          foregroundColor: controller.preferredCropAspectRatio == f?.toDouble()
              ? Colors.white
              : null,
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
        onPressed: () => controller.preferredCropAspectRatio = f?.toDouble(),
        child: Text(f == null ? 'Free' : '${f.numerator}:${f.denominator}', style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}