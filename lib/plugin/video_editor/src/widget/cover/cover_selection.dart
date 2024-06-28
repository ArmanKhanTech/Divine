import 'dart:async';
import 'package:flutter/material.dart';

import '../../utility/controller.dart';
import '../../model/cover_data.dart';
import '../../model/cover_style.dart';
import '../../model/transform_data.dart';
import '../../utility/helpers.dart';
import '../../utility/thumbnails.dart';
import '../crop/crop_grid_painter.dart';
import '../viewer/cover_viewer.dart';
import '../../utility/transform.dart';

class CoverSelection extends StatefulWidget {
  const CoverSelection({
    super.key,
    required this.controller,
    this.size = 60,
    this.quantity = 5,
    this.wrap,
    this.selectedCoverBuilder,
  });

  final VideoEditorController controller;

  final double size;

  final int quantity;

  final Wrap? wrap;

  final Widget Function(Widget selectedCover, Size)? selectedCoverBuilder;

  @override
  State<CoverSelection> createState() => _CoverSelectionState();
}

class _CoverSelectionState extends State<CoverSelection>
    with AutomaticKeepAliveClientMixin {
  Duration? startTrim, endTrim;

  Size layout = Size.zero;
  final ValueNotifier<Rect> rect = ValueNotifier<Rect>(Rect.zero);
  final ValueNotifier<TransformData> transform =
      ValueNotifier<TransformData>(const TransformData());

  late Stream<List<CoverData>> stream = (() => _generateCoverThumbnails())();

  @override
  void initState() {
    super.initState();
    startTrim = widget.controller.startTrim;
    endTrim = widget.controller.endTrim;
    widget.controller.addListener(scaleRect);
  }

  @override
  void dispose() {
    widget.controller.removeListener(scaleRect);
    transform.dispose();
    rect.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void scaleRect() {
    rect.value = calculateCroppedRect(widget.controller, layout);

    transform.value = TransformData.fromRect(
      rect.value,
      layout,
      Size.square(widget.size),
      null,
    );

    if (!widget.controller.isTrimming &&
        (startTrim != widget.controller.startTrim ||
            endTrim != widget.controller.endTrim)) {
      startTrim = widget.controller.startTrim;
      endTrim = widget.controller.endTrim;
      setState(() => stream = _generateCoverThumbnails());
    }
  }

  Stream<List<CoverData>> _generateCoverThumbnails() => generateCoverThumbnails(
        widget.controller,
        quantity: widget.quantity,
      );

  Size _calculateMaxLayout() {
    final ratio = rect.value == Rect.zero
        ? widget.controller.video.value.aspectRatio
        : rect.value.size.aspectRatio;

    return ratio < 1.0
        ? Size(widget.size * ratio, widget.size)
        : Size(widget.size, widget.size / ratio);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final wrap = widget.wrap ?? const Wrap();

    return StreamBuilder<List<CoverData>>(
        stream: stream,
        builder: (_, snapshot) {
          return snapshot.hasData
              ? ValueListenableBuilder<TransformData>(
                  valueListenable: transform,
                  builder: (_, transform, __) => Wrap(
                    direction: wrap.direction,
                    alignment: wrap.alignment,
                    spacing: widget.wrap?.spacing ?? 10.0,
                    runSpacing: widget.wrap?.runSpacing ?? 10.0,
                    runAlignment: wrap.runAlignment,
                    crossAxisAlignment: wrap.crossAxisAlignment,
                    textDirection: wrap.textDirection,
                    verticalDirection: wrap.verticalDirection,
                    clipBehavior: wrap.clipBehavior,
                    children: snapshot.data!
                        .map(
                          (coverData) => ValueListenableBuilder<CoverData?>(
                              valueListenable:
                                  widget.controller.selectedCoverNotifier,
                              builder: (context, selectedCover, __) {
                                final isSelected = coverData.sameTime(
                                    widget.controller.selectedCoverVal!);
                                final coverThumbnail = _buildSingleCover(
                                  coverData,
                                  transform,
                                  widget.controller.coverStyle,
                                  isSelected: isSelected,
                                );

                                if (isSelected &&
                                    widget.selectedCoverBuilder != null) {
                                  final size = _calculateMaxLayout();

                                  return widget.selectedCoverBuilder!(
                                    coverThumbnail,
                                    widget.controller.isRotated
                                        ? size.flipped
                                        : size,
                                  );
                                }

                                return coverThumbnail;
                              }),
                        )
                        .toList()
                        .cast<Widget>(),
                  ),
                )
              : const SizedBox();
        });
  }

  Widget _buildSingleCover(
    CoverData cover,
    TransformData transform,
    CoverSelectionStyle coverStyle, {
    required bool isSelected,
  }) {
    return RotatedBox(
      quarterTurns: widget.controller.rotation ~/ -90,
      child: InkWell(
        borderRadius: BorderRadius.circular(coverStyle.borderRadius),
        onTap: () => widget.controller.updateSelectedCover(cover),
        child: SizedBox.fromSize(
          size: _calculateMaxLayout(),
          child: Stack(
            children: [
              CropTransform(
                transform: transform,
                child: CoverViewer(
                  controller: widget.controller,
                  bytes: cover.thumbData!,
                  child: LayoutBuilder(builder: (_, constraints) {
                    Size size = constraints.biggest;
                    if (layout != size) {
                      layout = size;
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => scaleRect());
                    }

                    return RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: CropGridPainter(
                          rect.value,
                          radius: coverStyle.borderRadius / 2,
                          showGrid: false,
                          style: widget.controller.cropStyle,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(coverStyle.borderRadius),
                    border: Border.all(
                      color: isSelected
                          ? coverStyle.selectedBorderColor
                          : Colors.transparent,
                      width: coverStyle.borderWidth,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
