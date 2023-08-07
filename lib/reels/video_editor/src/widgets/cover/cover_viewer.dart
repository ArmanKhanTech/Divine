import 'package:flutter/material.dart';
import '../../controller.dart';
import '../../models/cover_data.dart';
import '../../models/transform_data.dart';
import '../../utilities/helpers.dart';
import '../crop/crop_mixin.dart';

class CoverViewer extends StatefulWidget {
  const CoverViewer({
    super.key,
    required this.controller,
    this.noCoverText = 'No selection',
  });

  final VideoEditorController controller;

  final String noCoverText;

  @override
  State<CoverViewer> createState() => _CoverViewerState();
}

class _CoverViewerState extends State<CoverViewer> with CropPreviewMixin {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(scaleRect);
    checkIfCoverIsNull();
  }

  @override
  void dispose() {
    widget.controller.removeListener(scaleRect);
    super.dispose();
  }

  void scaleRect() {
    layout = computeLayout(widget.controller);
    rect.value = calculateCroppedRect(widget.controller, layout);
    transform.value = TransformData.fromRect(
      rect.value,
      layout,
      viewerSize,
      widget.controller,
    );

    checkIfCoverIsNull();
  }

  void checkIfCoverIsNull() {
    if (widget.controller.selectedCoverVal!.thumbData == null) {
      widget.controller.generateDefaultCoverThumbnail();
    }
  }

  @override
  void updateRectFromBuild() => scaleRect();

  @override
  Widget buildView(BuildContext context, TransformData transform) {

    return ValueListenableBuilder(
      valueListenable: widget.controller.selectedCoverNotifier,
      builder: (_, CoverData? selectedCover, __) {
        if (selectedCover?.thumbData == null) {
          return Center(child: Text(widget.noCoverText));
        }

        return buildImageView(
          widget.controller,
          selectedCover!.thumbData!,
          transform,
        );
      },
    );
  }
}
