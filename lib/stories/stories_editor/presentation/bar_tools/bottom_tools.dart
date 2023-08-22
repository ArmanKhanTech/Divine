import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import '../../../../utilities/constants.dart';
import '../../domain/notifiers/control_notifier.dart';
import '../../domain/notifiers/draggable_widget_notifier.dart';
import '../../domain/notifiers/scroll_notifier.dart';
import '../../domain/services/save_as_image.dart';
import '../widgets/animated_on_tap_button.dart';

class BottomTools extends StatelessWidget {
  final GlobalKey contentKey;

  final Function(String imageUri) onDone;
  final Function(bool isLoading) onTapped;

  final Widget? onDoneButtonStyle;

  final Color? editorBackgroundColor;
  const BottomTools(
      {Key? key,
        required this.contentKey,
        required this.onDone,
        this.onDoneButtonStyle,
        this.editorBackgroundColor,
        required this.onTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Consumer3<ControlNotifier, ScrollNotifier, DraggableWidgetNotifier>(
      builder: (_, controlNotifier, scrollNotifier, itemNotifier, __) {

        return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 40.h),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: SizedBox(
                        child: _preViewContainer(
                          child: controlNotifier.mediaPath.isEmpty
                              ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: GestureDetector(
                                onTap: () {
                                  if (controlNotifier.mediaPath.isEmpty) {
                                    scrollNotifier.pageController
                                        .animateToPage(1,
                                        duration: const Duration(
                                            milliseconds: 300),
                                        curve: Curves.ease);
                                  }
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ))
                              : GestureDetector(
                            onTap: () {
                              controlNotifier.mediaPath = '';
                              itemNotifier.draggableWidget.removeAt(0);
                            },
                            child: Container(
                              height: 45,
                              width: 45,
                              color: Colors.transparent,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ),
                ),
                if (controlNotifier.middleBottomWidget != null)
                  Expanded(
                    child: Center(
                      child: Container(
                          alignment: Alignment.bottomCenter,
                          child: controlNotifier.middleBottomWidget),
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GradientText(
                            Constants.appName,
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w500,
                              fontFamily: GoogleFonts.merriweather().fontFamily,
                            ),
                            colors: const [
                              Colors.blue,
                              Colors.pink,
                              Colors.purple
                            ],
                          ),
                          const Text(
                            'Stories Creator',
                            style: TextStyle(
                                color: Colors.white38,
                                letterSpacing: 1.5,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Transform.scale(
                      scale: 0.9,
                      child: AnimatedOnTapButton(
                          onTap: () async {
                            String pngUri;
                            onTapped(true);
                            await takePicture(
                                contentKey: contentKey,
                                context: context,
                                saveToGallery: false
                            ).then((bytes) {
                              if (bytes != null) {
                                pngUri = bytes;
                                onDone(pngUri);
                                onTapped(false);
                              }
                            });
                          },
                          child: onDoneButtonStyle ??
                              Container(
                                height: 50,
                                width: 50,
                                padding: const EdgeInsets.only(
                                    left: 8, right: 5, top: 4, bottom: 4),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: Colors.white, width: 1.5)),
                                child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ]),
                              )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _preViewContainer({child}) {

    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1.4, color: Colors.white)),
      child: child,
    );
  }
}