import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/layer.dart';
import '../image_editor.dart';
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

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.chevron_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
            iconSize: 30.0,
            color: Colors.white,
          ),
          title: Text(
            i18n('Text'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
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
              icon: const Icon(Icons.check, size: 30),
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
              padding: const EdgeInsets.only(
                right: 20,
                left: 10
              ),
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
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(30),
                      hintText: Text(
                        i18n('Enter Text'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
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
                    cursorColor: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  color: Colors.black,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
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
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        child: Slider(
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
                      )
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
                        padding: const EdgeInsets.only(left: 30),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            i18n('Text Color'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: BarColorPicker(
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
                        ),
                        const SizedBox(
                            width: 15
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
                            width: 15
                        ),
                      ]),
                      const SizedBox(
                          height: 10.0
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            i18n('Black/White Color'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: BarColorPicker(
                              thumbColor: Colors.white,
                              cornerRadius: 10,
                              pickMode: PickMode.grey,
                              colorListener: (int value) {
                                setState(() {
                                  currentColor = Color(value);
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 15
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentColor = const Color(0xFFFFFFFF);
                            });
                          },
                          child: Text(
                              i18n('Reset'),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 15,
                              )
                          )
                        ),
                        const SizedBox(
                            width: 15
                        ),
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