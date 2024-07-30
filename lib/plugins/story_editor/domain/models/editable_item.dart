import 'package:flutter/material.dart';

import '../../../modal_gif_picker/src/models/client/gif.dart';
import '../../presentation/utilities/constants/app_enum.dart';

class EditableItem {
  bool deletePosition = false;

  Offset position = const Offset(0.0, 0.0);

  double scale = 1;
  double rotation = 0;

  ItemType type = ItemType.text;

  String text = '';

  List<String> textList = [];

  Color textColor = Colors.transparent;

  TextAlign textAlign = TextAlign.center;

  double fontSize = 20;

  int fontFamily = 0;
  int fontAnimationIndex = 0;

  Color backGroundColor = Colors.transparent;

  TextAnimationType animationType = TextAnimationType.none;

  GiphyGif gif = GiphyGif(id: '0');
}
