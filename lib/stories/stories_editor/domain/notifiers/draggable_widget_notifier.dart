import 'package:flutter/cupertino.dart';
import '../../modal_gif_picker/src/model/client/gif.dart';
import '../models/editable_item.dart';

class DraggableWidgetNotifier extends ChangeNotifier {
  List<EditableItem> _draggableWidget = [];
  List<EditableItem> get draggableWidget => _draggableWidget;
  set draggableWidget(List<EditableItem> item) {
    _draggableWidget = item;
    notifyListeners();
  }

  GiphyGif? _gif;
  GiphyGif? get giphy => _gif;
  set giphy(GiphyGif? giphy) {
    _gif = giphy;
    notifyListeners();
  }

  setDefaults() {
    _draggableWidget = [];
  }
}