import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/layer.dart';
import '../image_editor_plus.dart';
import 'color_picker.dart';

class TextEditorImage extends StatefulWidget {
  const TextEditorImage({super.key});

  @override
  createState() => _TextEditorImageState();
}

class _TextEditorImageState extends State<TextEditorImage> {
  TextEditingController name = TextEditingController();
  Color currentColor = Colors.white;
  double slider = 20.0;
  TextAlign align = TextAlign.left;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.alignLeft,
                  color: align == TextAlign.left
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  align = TextAlign.left;
                });
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.alignCenter,
                  color: align == TextAlign.center
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  align = TextAlign.center;
                });
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.alignRight,
                  color: align == TextAlign.right
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  align = TextAlign.right;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(
                  context,
                  TextLayerData(
                    background: Colors.transparent,
                    text: name.text,
                    color: currentColor,
                    size: slider.toDouble(),
                    align: align,
                  ),
                );
              },
              color: Colors.white,
              padding: const EdgeInsets.all(10),
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
              child: Column(children: [
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: size.height / 2.2,
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: Text(
                        i18n('Enter text here'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: slider,
                          fontWeight: FontWeight.bold,
                        ),
                      ).data,
                      alignLabelWithHint: true,
                    ),
                    scrollPadding: const EdgeInsets.all(20.0),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 99999,
                    style: TextStyle(
                      color: currentColor,
                      fontSize: slider,
                    ),
                    textAlign: align,
                    autofocus: true,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  color: Colors.black,
                  child: Column(
                    children: [
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
                          value: slider,
                          min: 0.0,
                          max: 100.0,
                          onChangeEnd: (v) {
                            setState(() {
                              slider = v;
                            });
                          },
                          onChanged: (v) {
                            setState(() {
                              slider = v;
                            });
                          }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            i18n('Text Color'),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        )
                      ),
                      Row(children: [
                        const SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: BarColorPicker(
                            width: 300,
                            thumbColor: Colors.white,
                            cornerRadius: 10,
                            pickMode: PickMode.color,
                            colorListener: (int value) {
                              setState(() {
                                currentColor = Color(value);
                              });
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentColor = Colors.white;
                            });
                          },
                          child: Text(
                            i18n('Reset'),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                            )
                          ),
                        ),
                        const SizedBox(
                          width: 10.0
                        )
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
    );
  }
}