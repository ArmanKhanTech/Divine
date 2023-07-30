import 'package:divine/stories/stories_editor/presentation/text_editor_widget/widgets/animation_selector.dart';
import 'package:divine/stories/stories_editor/presentation/text_editor_widget/widgets/font_selector.dart';
import 'package:divine/stories/stories_editor/presentation/text_editor_widget/widgets/text_feild_widget.dart';
import 'package:divine/stories/stories_editor/presentation/text_editor_widget/widgets/top_text_tools.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/editable_item.dart';
import '../../domain/notifiers/control_notifier.dart';
import '../../domain/notifiers/draggable_widget_notifier.dart';
import '../../domain/notifiers/text_editing_notifier.dart';
import '../utilities/constants/app_enum.dart';
import '../widgets/color_selector.dart';
import '../widgets/size_slider_widget.dart';

class TextEditor extends StatefulWidget {
  final BuildContext context;
  const TextEditor({Key? key, required this.context}) : super(key: key);

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  List<String> splitList = [];

  String sequenceList = '';
  String lastSequenceList = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final editorNotifier = Provider.of<TextEditingNotifier>(widget.context, listen: false);
      editorNotifier
        ..textController.text = editorNotifier.text
        ..fontFamilyController = PageController(viewportFraction: .125);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Material(
        color: Colors.transparent,
        child: Consumer2<ControlNotifier, TextEditingNotifier>(
          builder: (_, controlNotifier, editorNotifier, __) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: GestureDetector(
                onTap: () => _onTap(context, controlNotifier, editorNotifier),
                child: Container(
                    decoration:
                    BoxDecoration(color: Colors.black.withOpacity(0.5)),
                    height: MediaQuery.of(context).size.height * 100,
                    width: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child: TextFieldWidget(),
                        ),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.only(
                                left: 10
                              ),
                              child: SizeSliderWidget()
                          ),
                        ),

                        SafeArea(
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: TopTextTools(
                                onDone: () => _onTap(
                                    context, controlNotifier, editorNotifier),
                              )),
                        ),

                        Positioned(
                          child: Visibility(
                            visible: editorNotifier.isFontFamily &&
                                !editorNotifier.isTextAnimation,
                            child: const Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: FontSelector(),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          child: Visibility(
                              visible: !editorNotifier.isFontFamily &&
                                  !editorNotifier.isTextAnimation,
                              child: const Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: ColorSelector(),
                                ),
                              )),
                        ),

                        Positioned(
                          child: Visibility(
                              visible: editorNotifier.isTextAnimation,
                              child: const Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: AnimationSelector(),
                                ),
                              )),
                        ),
                      ],
                    )),
              ),
            );
          },
        ));
  }

  void _onTap(context, ControlNotifier controlNotifier,
      TextEditingNotifier editorNotifier) {
    final editableItemNotifier = Provider.of<DraggableWidgetNotifier>(context, listen: false);

    if (editorNotifier.text.trim().isNotEmpty) {
      splitList = editorNotifier.text.split(' ');
      for (int i = 0; i < splitList.length; i++) {
        if (i == 0) {
          editorNotifier.textList.add(splitList[0]);
          sequenceList = splitList[0];
        } else {
          lastSequenceList = sequenceList;
          editorNotifier.textList.add('$sequenceList ${splitList[i]}');
          sequenceList = '$lastSequenceList ${splitList[i]}';
        }
      }

      editableItemNotifier.draggableWidget.add(EditableItem()
        ..type = ItemType.text
        ..text = editorNotifier.text.trim()
        ..backGroundColor = editorNotifier.backGroundColor
        ..textColor = controlNotifier.colorList![editorNotifier.textColor]
        ..fontFamily = editorNotifier.fontFamilyIndex
        ..fontSize = editorNotifier.textSize
        ..fontAnimationIndex = editorNotifier.fontAnimationIndex
        ..textAlign = editorNotifier.textAlign
        ..textList = editorNotifier.textList
        ..animationType =
        editorNotifier.animationList[editorNotifier.fontAnimationIndex]
        ..position = const Offset(0.0, 0.0));
      editorNotifier.setDefaults();
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
    } else {
      editorNotifier.setDefaults();
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
    }
  }
}