import 'package:divine/stories/stories_editor/modal_gif_picker/src/model/client/gif.dart';
import 'package:divine/stories/stories_editor/modal_gif_picker/src/model/client/languages.dart';
import 'package:divine/stories/stories_editor/modal_gif_picker/src/model/client/rating.dart';
import 'package:divine/stories/stories_editor/modal_gif_picker/src/model/giphy_preview_types.dart';
import 'package:divine/stories/stories_editor/modal_gif_picker/src/widgets/giphy_context.dart';
import 'package:divine/stories/stories_editor/modal_gif_picker/src/widgets/giphy_search_view.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

typedef ErrorListener = void Function(dynamic error);

class ModalGifPicker {
  static Future<GiphyGif?> pickModalSheetGif(
      {required BuildContext context,
      required String apiKey,
      String rating = GiphyRating.g,
      String lang = GiphyLanguage.english,
      bool sticker = false,
      GiphyPreviewType? previewType = GiphyPreviewType.previewGif,
      Color backGroundColor = Colors.black,
      Color textColor = Colors.white,
      Color backDropColor = Colors.white,
      Color topDragColor = Colors.white54,
      double crossAxisSpacing = 5,
      double mainAxisSpacing = 5,
      int crossAxisCount = 2,
      double childAspectRatio = 1.6,
      ErrorListener? onError}) async {
    GiphyGif? result;

    await showModalBottomSheet(
        context: context,
        barrierColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {

          return FractionallySizedBox(
            heightFactor: 0.9,
            child: DraggableScrollableSheet(
              initialChildSize: 0.9,
              maxChildSize: 1,
              minChildSize: 0.9,
              expand: true,
              builder: (BuildContext context, ScrollController scrollController) {

                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            topLeft: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 10,
                              spreadRadius: 16,
                              color: backGroundColor.withOpacity(0.3),
                              offset: const Offset(0, 16))
                        ]),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          topLeft: Radius.circular(16)),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(
                          sigmaX: 40.0,
                          sigmaY: 40.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              color: backDropColor.withOpacity(0.5),
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  topLeft: Radius.circular(16)),
                              border: Border.all(
                                width: 1.5,
                                color: Colors.transparent,
                              )),
                          child: Center(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    decoration: BoxDecoration(
                                        color: topDragColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: GiphyContext(
                                      previewType: previewType,
                                      apiKey: apiKey,
                                      showPreviewPage: false,
                                      rating: rating,
                                      searchDelay: const Duration(milliseconds: 300),
                                      language: lang,
                                      sticker: sticker,
                                      onError: onError ??
                                          (error) => _showErrorDialog(context, error),
                                      onSelected: (gif) {
                                        result = gif;
                                        Navigator.pop(context);
                                      },
                                      decorator: null,
                                      child: GiphySearchView(
                                        sheetScrollController: scrollController,
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: childAspectRatio,
                                        crossAxisSpacing: crossAxisSpacing,
                                        mainAxisSpacing: mainAxisSpacing,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });

    return result;
  }

  static void _showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 1,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            height: 260,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black, offset: Offset(0, 1), blurRadius: 3),
                ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 15, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Giphy Error',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    '$error',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
