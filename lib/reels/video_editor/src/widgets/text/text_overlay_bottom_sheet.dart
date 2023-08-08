import 'package:flutter/material.dart';

import '../../../../../posts/image_editor/modules/color_picker.dart';
import '../../controller.dart';

class TextOverlayBottomSheet extends StatefulWidget {
  final VideoEditorController controller;

  const TextOverlayBottomSheet({
    super.key, required this.controller,
  });

  @override
  createState() => _TextOverlayBottomSheetState();
}

class _TextOverlayBottomSheetState extends State<TextOverlayBottomSheet> {
  double slider = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 420,
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          border: Border(
            top: BorderSide(width: 1, color: Colors.white),
            bottom: BorderSide(width: 0, color: Colors.white),
            left: BorderSide(width: 0, color: Colors.white),
            right: BorderSide(width: 0, color: Colors.white),
          )
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Text Size',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Slider(
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
              value: widget.controller.textSize,
              min: 0.0,
              max: 100.0,
              onChangeEnd: (v) {
                setState(() {
                  widget.controller.textSize = v.toDouble();
                });
              },
              onChanged: (v) {
                setState(() {
                  widget.controller.textSize = v.toDouble();
                });
              }),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.only(left: 20),
                child: const Text(
                  'Text Color',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              Row(children: [
                const SizedBox(width: 10),
                Expanded(
                  child: BarColorPicker(
                    width: 300,
                    thumbColor: Colors.white,
                    initialColor: widget.controller.textColor,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() {
                        widget.controller.textColor = Color(value);
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.controller.textColor = Colors.white;
                    });
                  },
                  child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 20),
                child: const Text(
                  'Text Background Color',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              Row(children: [
                const SizedBox(width: 10),
                Expanded(
                  child: BarColorPicker(
                    width: 300,
                    initialColor: widget.controller.textBgColor,
                    thumbColor: Colors.white,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() {
                        widget.controller.textBgColor = Color(value);
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.controller.textBgColor = Colors.transparent;
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 20),
                child: const Text(
                  'Text Background Opacity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              Row(children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 255,
                    divisions: 255,
                    value: widget.controller.textBgColorOpacity,
                    thumbColor: Colors.white,
                    onChanged: (double value) {
                      setState(() {
                        widget.controller.textBgColorOpacity = value.toInt() as double;
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.controller.textBgColorOpacity = 0;
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ]),
            ]),
          ),
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    widget.controller.textOverlay = false;
                  });
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}