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
          Center(
            child: Text(
              i18n('Text Size'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
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
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  i18n('Text Color'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.color = Colors.black;
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
              Container(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  i18n('Text Background Color'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  i18n('Text Background Opacity'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
                    value: widget.layer.backgroundOpacity.toDouble(),
                    thumbColor: Colors.white,
                    onChanged: (double value) {
                      setState(() {
                        widget.layer.backgroundOpacity = value.toInt();
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.backgroundOpacity = 0;
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
                const SizedBox(width: 10),
              ]),
            ]),
          ),
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