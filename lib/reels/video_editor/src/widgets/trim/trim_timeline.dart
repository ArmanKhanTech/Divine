import 'dart:math';
import 'package:flutter/material.dart';
import '../../controller.dart';

class TrimTimeline extends StatelessWidget {
  const TrimTimeline({
    super.key,
    required this.controller,
    this.quantity = 8,
    this.padding = EdgeInsets.zero,
    this.localSeconds = 's',
    this.textStyle,
  });

  final VideoEditorController controller;

  final int quantity;

  final EdgeInsets padding;

  final String localSeconds;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(builder: (_, constraint) {
      final int count =
          (max(1, (constraint.maxWidth / MediaQuery.of(context).size.width)) *
                  min(quantity, controller.videoDuration.inMilliseconds ~/ 100))
              .toInt();
      final gap = controller.videoDuration.inMilliseconds ~/ (count - 1);

      return Padding(
        padding: padding,
        child: IntrinsicWidth(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(count, (i) {
              final t = Duration(milliseconds: i * gap);
              final text =
                  (t.inMilliseconds / 1000).toStringAsFixed(1).padLeft(2, '0');

              return Text(
                '$text$localSeconds',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}
