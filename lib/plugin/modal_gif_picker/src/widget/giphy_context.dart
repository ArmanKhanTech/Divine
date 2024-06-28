import 'package:flutter/material.dart';

import '../../modal_gif_picker.dart';
import '../model/client/gif.dart';
import '../model/client/languages.dart';
import '../model/client/rating.dart';
import '../model/giphy_decorator.dart';
import '../model/giphy_preview_types.dart';

class GiphyContext extends InheritedWidget {
  final String apiKey;
  final String rating;
  final String language;

  final bool sticker;
  final bool showPreviewPage;

  final ValueChanged<GiphyGif>? onSelected;

  final ErrorListener? onError;
  final GiphyPreviewType? previewType;

  final GiphyDecorator? decorator;

  final String searchText;

  final Duration searchDelay;

  const GiphyContext({
    Key? key,
    required Widget child,
    required this.apiKey,
    this.rating = GiphyRating.g,
    this.language = GiphyLanguage.english,
    this.sticker = false,
    this.onSelected,
    this.onError,
    this.showPreviewPage = true,
    this.searchText = 'Search Giphy',
    this.searchDelay = const Duration(milliseconds: 500),
    required this.decorator,
    this.previewType,
  }) : super(key: key, child: child);

  void select(GiphyGif gif) => onSelected?.call(gif);
  void error(dynamic error) => onError?.call(error);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static GiphyContext of(BuildContext context) {
    final settings = context
        .getElementForInheritedWidgetOfExactType<GiphyContext>()
        ?.widget as GiphyContext?;

    if (settings == null) {
      throw 'Required GiphyContext widget not found. Make sure to wrap your widget with GiphyContext.';
    }

    return settings;
  }
}
