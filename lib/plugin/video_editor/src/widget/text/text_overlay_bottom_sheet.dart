import 'package:flutter/material.dart';

import '../../../../image_editor/module/color_picker.dart';
import '../../utility/controller.dart';

class TextOverlayBottomSheet extends StatefulWidget {
  final VideoEditorController controller;
  final Function onUpdate;

  const TextOverlayBottomSheet({
    super.key,
    required this.controller,
    required this.onUpdate,
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
      height: 340,
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          border: Border(
            top: BorderSide(width: 1, color: Colors.white),
            bottom: BorderSide(width: 0, color: Colors.white),
            left: BorderSide(width: 0, color: Colors.white),
            right: BorderSide(width: 0, color: Colors.white),
          )),
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
            onChanged: (v) {
              setState(() {
                widget.controller.textSize = v;
                widget.onUpdate();
              });
            },
            onChangeEnd: (v) {
              setState(() {
                widget.controller.textSize = v;
                widget.onUpdate();
              });
            },
          ),
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
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.controller.textColor = Colors.white;
                      widget.onUpdate();
                    });
                  },
                  child: const Text('Reset',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
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
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.controller.textBgColor = Colors.transparent;
                      widget.onUpdate();
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
            ]),
          ),
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    widget.controller.textOverlay = false;
                    widget.onUpdate();
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
