import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../posts/image_editor/modules/color_picker.dart';
import '../src/utilities/controller.dart';

class TextOverlayScreen extends StatefulWidget {
  final VideoEditorController controller;

  const TextOverlayScreen({super.key, required this.controller});

  @override
  createState() => _TextOverlayScreenState();
}

class _TextOverlayScreenState extends State<TextOverlayScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Text',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
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
                  color: widget.controller.textAlign == TextAlign.left
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  widget.controller.textAlign = TextAlign.left;
                });
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.alignCenter,
                  color: widget.controller.textAlign == TextAlign.center
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  widget.controller.textAlign = TextAlign.center;
                });
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.alignRight,
                  color: widget.controller.textAlign == TextAlign.right
                      ? Colors.white
                      : Colors.white.withAlpha(80)),
              onPressed: () {
                setState(() {
                  widget.controller.textAlign = TextAlign.right;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, size: 30),
              onPressed: () {
                widget.controller.setText(widget.controller.text);
                widget.controller.setTextSize(widget.controller.textSize);
                widget.controller.setTextColor(widget.controller.textColor);
                widget.controller.setTextAlign(widget.controller.textAlign);
                widget.controller.setTextOverlay(true);
                Navigator.pop(context);
              },
              color: Colors.white,
              padding: const EdgeInsets.only(
                  right: 22,
                  left: 10
              ),
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
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(30),
                    hintText: 'Enter your text here',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: widget.controller.textSize,
                    ),
                    alignLabelWithHint: true,
                  ),
                  scrollPadding: const EdgeInsets.all(20.0),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 99999,
                  style: TextStyle(
                    color: widget.controller.textColor,
                    fontSize: widget.controller.textSize,
                  ),
                  textAlign: widget.controller.textAlign,
                  autofocus: true,
                  cursorColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      widget.controller.text = value;
                    });
                  },
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Text Size',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
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
                            widget.controller.textSize = v;
                          });
                        },
                        onChanged: (v) {
                          setState(() {
                            widget.controller.textSize  = v;
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
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Text Color',
                        style: TextStyle(
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
                              widget.controller.textColor = Color(value);
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
                            widget.controller.textColor = Colors.white;
                          });
                        },
                        child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                            )
                        ),
                      ),
                    ]),
                    const SizedBox(
                        height: 10.0
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Black/White Color',
                        style: TextStyle(
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
                              widget.controller.textColor = Color(value);
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
                              widget.controller.textColor = const Color(0xFFFFFFFF);
                            });
                          },
                          child: const Text(
                              'Reset',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                              )
                          )
                      ),
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