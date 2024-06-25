import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/notifiers/text_editing_notifier.dart';
import '../../widgets/tool_button.dart';

class TopTextTools extends StatelessWidget {
  final void Function() onDone;
  const TopTextTools({Key? key, required this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TextEditingNotifier>(
      builder: (context, editorNotifier, child) {
        return Container(
          padding: const EdgeInsets.only(top: 15),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToolButton(
                    onTap: () {
                      editorNotifier.isFontFamily =
                          !editorNotifier.isFontFamily;
                      editorNotifier.isTextAnimation = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (editorNotifier.fontFamilyController.hasClients) {
                          editorNotifier.fontFamilyController.animateToPage(
                              editorNotifier.fontFamilyIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        }
                      });
                    },
                    child: Transform.scale(
                        scale: !editorNotifier.isFontFamily ? 0.8 : 1.3,
                        child: !editorNotifier.isFontFamily
                            ? const ImageIcon(
                                AssetImage('assets/icons/text.png'),
                                size: 20,
                                color: Colors.white,
                              )
                            : Image.asset(
                                'assets/icons/circular_gradient.png')),
                  ),
                  ToolButton(
                    onTap: editorNotifier.onAlignmentChange,
                    child: Transform.scale(
                        scale: 0.8,
                        child: Icon(
                          editorNotifier.textAlign == TextAlign.center
                              ? Icons.format_align_center
                              : editorNotifier.textAlign == TextAlign.right
                                  ? Icons.format_align_right
                                  : Icons.format_align_left,
                          color: Colors.white,
                        )),
                  ),
                  ToolButton(
                    onTap: editorNotifier.onBackGroundChange,
                    child: Transform.scale(
                        scale: 0.7,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.only(left: 5, bottom: 3),
                            child: ImageIcon(
                              AssetImage('assets/icons/font_backGround.png'),
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ),
                  ToolButton(
                    onTap: () {
                      editorNotifier.isTextAnimation =
                          !editorNotifier.isTextAnimation;

                      if (editorNotifier.isTextAnimation) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (editorNotifier
                              .textAnimationController.hasClients) {
                            editorNotifier.textAnimationController
                                .animateToPage(
                                    editorNotifier.fontAnimationIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn);
                          }
                        });
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (editorNotifier.fontFamilyController.hasClients) {
                            editorNotifier.fontFamilyController.animateToPage(
                                editorNotifier.fontFamilyIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          }
                        });
                      }
                    },
                    child: Transform.scale(
                        scale: 0.7,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(0),
                            child: ImageIcon(
                              AssetImage('assets/icons/video_trim.png'),
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ),
                  ToolButton(
                    onTap: onDone,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    backGroundColor: Colors.black12,
                    child: Transform.scale(
                        scale: 0.7,
                        child: const ImageIcon(
                          AssetImage('assets/icons/check.png'),
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
