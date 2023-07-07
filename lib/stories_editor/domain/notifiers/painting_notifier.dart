import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../presentation/utils/constants/app_enum.dart';
import '../models/painting_model.dart';

class PaintingNotifier extends ChangeNotifier {
  List<PaintingModel> _lines = <PaintingModel>[];

  int _lineColor = 0;

  double _lineWidth = 10;

  int _selectedToolIndex = 0;

  PaintingType _paintingType = PaintingType.pen;

  StreamController<List<PaintingModel>> _linesStreamController =
  StreamController<List<PaintingModel>>.broadcast();

  StreamController<PaintingModel> _currentLineStreamController =
  StreamController<PaintingModel>.broadcast();

  List<PaintingModel> get lines => _lines;
  int get lineColor => _lineColor;
  double get lineWidth => _lineWidth;
  int get selectedToolIndex => _selectedToolIndex;
  StreamController<List<PaintingModel>> get linesStreamController =>
      _linesStreamController;
  StreamController<PaintingModel> get currentLineStreamController =>
      _currentLineStreamController;
  PaintingType get paintingType => _paintingType;

  set lines(List<PaintingModel> line) {
    _lines = line;
    notifyListeners();
  }

  set itemLine(List<Widget> item) {
    notifyListeners();
  }

  set lineColor(int color) {
    _lineColor = color;
    notifyListeners();
  }

  set lineWidth(double width) {
    _lineWidth = width;
    notifyListeners();
  }

  set selectedToolIndex(int index) {
    _selectedToolIndex = index;
    notifyListeners();
  }

  set linesStreamController(StreamController<List<PaintingModel>> stream) {
    _linesStreamController = stream;
    notifyListeners();
  }

  set currentLineStreamController(StreamController<PaintingModel> stream) {
    _currentLineStreamController = stream;
    notifyListeners();
  }

  set paintingType(PaintingType type) {
    _paintingType = type;
    notifyListeners();
  }

  clearAll() {
    _lines = [];
    notifyListeners();
  }

  removeLast() {
    if (_lines.isNotEmpty) {
      _lines.removeLast();
      notifyListeners();
    } else {
      _lines = [];
      notifyListeners();
    }
  }

  resetDefaults() {
    _lineWidth = 10;
    _lineColor = 0;
    _paintingType = PaintingType.pen;
    notifyListeners();
  }

  closeConnection() {
    _currentLineStreamController.close();
    _linesStreamController.close();
  }
}