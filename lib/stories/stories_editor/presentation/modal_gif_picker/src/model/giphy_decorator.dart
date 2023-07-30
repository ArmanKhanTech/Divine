import 'package:flutter/material.dart';

class GiphyDecorator {
  final bool showAppBar;

  final ThemeData? giphyTheme;

  final double searchElevation;

  const GiphyDecorator({
    this.showAppBar = true,
    this.giphyTheme,
    this.searchElevation = 0.0,
  });
}
