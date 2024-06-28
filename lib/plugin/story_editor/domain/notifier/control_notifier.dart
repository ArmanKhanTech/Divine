import 'package:flutter/cupertino.dart';

import '../../presentation/utility/constants/app_colors.dart';
import '../../presentation/utility/constants/font_family.dart';

class ControlNotifier extends ChangeNotifier {
  String _giphyKey = '';
  String get giphyKey => _giphyKey;
  set giphyKey(String key) {
    _giphyKey = key;
    notifyListeners();
  }

  int _gradientIndex = 0;
  int get gradientIndex => _gradientIndex;
  set gradientIndex(int index) {
    _gradientIndex = index;
    notifyListeners();
  }

  bool _isTextEditing = false;
  bool get isTextEditing => _isTextEditing;
  set isTextEditing(bool val) {
    _isTextEditing = val;
    notifyListeners();
  }

  bool _isPainting = false;
  bool get isPainting => _isPainting;
  set isPainting(bool painting) {
    _isPainting = painting;
    notifyListeners();
  }

  List<String>? _fontList = AppFonts.fontFamilyList;
  List<String>? get fontList => _fontList;
  set fontList(List<String>? fonts) {
    _fontList = fonts;
    notifyListeners();
  }

  bool _isCustomFontList = false;
  bool get isCustomFontList => _isCustomFontList;
  set isCustomFontList(bool key) {
    _isCustomFontList = key;
    notifyListeners();
  }

  List<List<Color>>? _gradientColors = AppColors.gradientBackgroundColors;
  List<List<Color>>? get gradientColors => _gradientColors;
  set gradientColors(List<List<Color>>? color) {
    _gradientColors = color;
    notifyListeners();
  }

  Widget? _middleBottomWidget;
  Widget? get middleBottomWidget => _middleBottomWidget;
  set middleBottomWidget(Widget? widget) {
    _middleBottomWidget = widget;
    notifyListeners();
  }

  Future<bool>? _exitDialogWidget;
  Future<bool>? get exitDialogWidget => _exitDialogWidget;
  set exitDialogWidget(Future<bool>? widget) {
    _exitDialogWidget = widget;
    notifyListeners();
  }

  List<Color>? _colorList = AppColors.defaultColors;
  List<Color>? get colorList => _colorList;
  set colorList(List<Color>? value) {
    _colorList = value;
    notifyListeners();
  }

  String _mediaPath = '';
  String get mediaPath => _mediaPath;
  set mediaPath(String media) {
    _mediaPath = media;
    notifyListeners();
  }

  bool _isPhotoFilter = false;
  bool get isPhotoFilter => _isPhotoFilter;
  set isPhotoFilter(bool filter) {
    _isPhotoFilter = filter;
    notifyListeners();
  }
}
