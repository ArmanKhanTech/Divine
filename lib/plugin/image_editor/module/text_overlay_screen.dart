import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../data/layer.dart';
import '../image_editor_pro.dart';
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30.0,
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 3),
        ),
        title: Text(
          i18n('Text'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.black,
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
            padding: const EdgeInsets.only(right: 22, left: 10),
          )
        ],
      ),
      backgroundColor: Colors.black,
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
                  hintText: 'Enter your text here',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: slider,
                  ),
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
              height: 20,
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      i18n('Text Color'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(children: [
                    Expanded(
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
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          currentColor = Colors.white;
                        });
                      },
                      child: Text(i18n('Reset'),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                          )),
                    ),
                  ]),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      i18n('Black/White Color'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(children: [
                    Expanded(
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
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            currentColor = const Color(0xFFFFFFFF);
                          });
                        },
                        child: Text(i18n('Reset'),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                            ))),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
