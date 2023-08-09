import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../posts/image_editor/modules/color_picker.dart';
import '../src/controller.dart';

class TextOverlayScreen extends StatefulWidget {
  final VideoEditorController controller;

  const TextOverlayScreen({super.key, required this.controller});

  @override
  createState() => _TextOverlayScreenState();
}

class _TextOverlayScreenState extends State<TextOverlayScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Text',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.white,
            padding: const EdgeInsets.all(10),
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
              icon: const Icon(Icons.check),
              onPressed: () {
                widget.controller.setText(widget.controller.text);
                widget.controller.setTextSize(widget.controller.textSize);
                widget.controller.setTextColor(widget.controller.textColor);
                widget.controller.setTextAlign(widget.controller.textAlign);
                widget.controller.setTextOverlay(true);
                Navigator.pop(context);
              },
              color: Colors.white,
              padding: const EdgeInsets.all(10),
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
              // TODO:Fix init text color
              SizedBox(
                height: size.height / 2.2,
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'Enter Text',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
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
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: widget.controller.textAlign,
                  autofocus: true,
                  onChanged: (text) {
                    setState(() {
                      widget.controller.text = text;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                color: Colors.black,
                child: Column(
                  children: [
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
                            widget.controller.textSize = v;
                          });
                        },
                        onChanged: (v) {
                          setState(() {
                            widget.controller.textSize = v;
                          });
                        }),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    const Padding(
                        padding: EdgeInsets.only(
                            left: 20
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Text Color',
                            textAlign: TextAlign.left,
                            style: TextStyle(
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
                          initialColor: widget.controller.textColor,
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
                            )
                        ),
                      ),
                      const SizedBox(
                          width: 10.0
                      )
                    ]),
                    const SizedBox(
                        height: 10.0
                    ),
                    const Padding(
                        padding: EdgeInsets.only(
                            left: 20
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Text Black/White Color',
                            textAlign: TextAlign.left,
                            style: TextStyle(
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
                          initialColor: widget.controller.textColor,
                          pickMode: PickMode.grey,
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
                            widget.controller.textColor = const Color(0xFFFFFFFF);
                          });
                        },
                        child: const Text(
                            'Reset',
                            style: TextStyle(
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
    );
  }
}