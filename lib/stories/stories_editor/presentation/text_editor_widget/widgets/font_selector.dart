import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../domain/notifiers/control_notifier.dart';
import '../../../domain/notifiers/text_editing_notifier.dart';
import '../../widgets/animated_on_tap_button.dart';

class FontSelector extends StatelessWidget {
  const FontSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();

    return Consumer2<TextEditingNotifier, ControlNotifier>(
      builder: (context, editorNotifier, controlNotifier, child) {

        return Container(
          height: screenUtil.screenWidth * 0.1,
          width: screenUtil.screenWidth,
          alignment: Alignment.center,
          child: PageView.builder(
            controller: editorNotifier.fontFamilyController,
            itemCount: controlNotifier.fontList!.length,
            onPageChanged: (index) {
              editorNotifier.fontFamilyIndex = index;
              HapticFeedback.heavyImpact();
            },
            physics: const BouncingScrollPhysics(),
            allowImplicitScrolling: true,
            pageSnapping: false,
            itemBuilder: (context, index) {

              return AnimatedOnTapButton(
                onTap: () {
                  editorNotifier.fontFamilyIndex = index;
                  editorNotifier.fontFamilyController.jumpToPage(index);
                },
                child: Container(
                  height: screenUtil.screenWidth * 0.1,
                  width: screenUtil.screenWidth * 0.1,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: index == editorNotifier.fontFamilyIndex
                          ? Colors.white
                          : Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  child: Center(
                    child: Text(
                      'Aa',
                      style: TextStyle(
                          fontFamily: controlNotifier.fontList![index],
                          package: controlNotifier.isCustomFontList
                              ? null
                              : 'stories_editor')
                          .copyWith(
                          color: index == editorNotifier.fontFamilyIndex
                              ? Colors.red
                              : Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}