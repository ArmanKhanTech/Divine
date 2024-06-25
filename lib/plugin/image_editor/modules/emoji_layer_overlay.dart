import 'package:flutter/material.dart';
import '../data/layer.dart';
import '../image_editor_pro.dart';

class EmojiLayerOverlay extends StatefulWidget {
  final int index;
  final EmojiLayerData layer;
  final Function onUpdate;

  const EmojiLayerOverlay({
    super.key,
    required this.layer,
    required this.index,
    required this.onUpdate,
  });

  @override
  createState() => _EmojiLayerOverlayState();
}

class _EmojiLayerOverlayState extends State<EmojiLayerOverlay> {
  double slider = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
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
          Center(
            child: Text(
              i18n('Size Adjust'),
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
                  // print(v.toDouble());
                  widget.layer.size = v.toDouble();
                  widget.onUpdate();
                });
              }),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  removedLayers.add(layers.removeAt(widget.index));
                  Navigator.pop(context);
                  widget.onUpdate();
                  // back(context);
                  // setState(() {});
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
