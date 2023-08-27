import 'package:flutter/material.dart';
import '../data/layer.dart';
import '../image_editor.dart';
import 'color_picker.dart';

class TextLayerOverlay extends StatefulWidget {
  final int index;
  final TextLayerData layer;
  final Function onUpdate;

  const TextLayerOverlay({
    super.key,
    required this.layer,
    required this.index,
    required this.onUpdate,
  });

  @override
  createState() => _TextLayerOverlayState();
}

class _TextLayerOverlayState extends State<TextLayerOverlay> {
  double slider = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 380,
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                i18n('Text Size'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Slider(
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
              value: widget.layer.size,
              min: 0.0,
              max: 100.0,
              onChangeEnd: (v) {
                setState(() {
                  widget.layer.size = v.toDouble();
                  widget.onUpdate();
                });
              },
              onChanged: (v) {
                setState(() {
                  slider = v;
                  widget.layer.size = v.toDouble();
                  widget.onUpdate();
                });
              }),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                i18n('Text Color'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Row(children: [
                Expanded(
                  child: BarColorPicker(
                    thumbColor: Colors.white,
                    initialColor: widget.layer.color,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() {
                        widget.layer.color = Color(value);
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                const SizedBox(
                    width: 10
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.color = Colors.white;
                      widget.onUpdate();
                    });
                  },
                  child: Text(i18n('Reset'),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Text(
                i18n('Text Background Color'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Row(children: [
                Expanded(
                  child: BarColorPicker(
                    initialColor: widget.layer.background,
                    thumbColor: Colors.white,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() {
                        widget.layer.background = Color(value);
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                const SizedBox(
                    width: 10
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.background = Colors.transparent;
                      widget.onUpdate();
                    });
                  },
                  child: Text(
                    i18n('Reset'),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                i18n('Text Background Opacity'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Slider(
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
              value: widget.layer.backgroundOpacity.toDouble(),
              thumbColor: Colors.white,
              min: 0.0,
              max: 100.0,
              onChanged: (v) {
                setState(() {
                  widget.layer.backgroundOpacity = v.toInt();
                  widget.onUpdate();
                });
              }),
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  removedLayers.add(layers.removeAt(widget.index));
                  Navigator.pop(context);
                  widget.onUpdate();
                },
                child: Text(
                  i18n('Remove'),
                  style: const TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}