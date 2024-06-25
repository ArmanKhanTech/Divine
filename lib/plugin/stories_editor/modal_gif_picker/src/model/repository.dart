import 'dart:async';
import 'dart:collection';
import '../../modal_gif_picker.dart';

abstract class Repository<T> {
  final HashMap<int, T> _cache = HashMap<int, T>();
  final Set<int> _pagesLoading = <int>{};
  final HashMap<int, Completer<T>> _completers = HashMap<int, Completer<T>>();
  final int pageSize;
  final ErrorListener? onError;
  int _totalCount = 0;

  Repository({required this.pageSize, this.onError});

  int get totalCount => _totalCount;

  Future<T> get(int index) {
    assert(index == 0 || index > 0 && index < _totalCount);

    final value = _cache[index];

    if (value != null) {
      return Future.value(value);
    }

    final page = index ~/ pageSize;

    if (!_pagesLoading.contains(page)) {
      _pagesLoading.add(page);
      getPage(page).then(_onPageRetrieved,
          onError: (error, stackTrace) =>
              _onPageError(page, error, stackTrace));
    }

    var completer = _completers[index];
    if (completer == null) {
      completer = Completer<T>();
      _completers[index] = completer;
    }

    return completer.future;
  }

  void _onPageRetrieved(Page<T> page) {
    _pagesLoading.remove(page);
    _totalCount = page.totalCount;

    if (_totalCount == 0) {
      for (var c in _completers.values) {
        c.complete(null);
      }
      _completers.clear();
    } else {
      for (var i = 0; i < page.values.length; i++) {
        // store value
        final index = page.page * pageSize + i;
        final value = page.values[i];
        _cache[index] = value;

        final completer = _completers.remove(index);
        completer?.complete(value);
      }
    }
  }

  void _onPageError(int page, Object error, StackTrace stackTrace) {
    _pagesLoading.remove(page);

    for (var i = 0; i < pageSize; i++) {
      final index = page * pageSize + i;
      final completer = _completers.remove(index);
      completer?.completeError(error, stackTrace);
    }

    onError?.call(error);
  }

  Future<Page<T>> getPage(int page);
}

class Page<T> {
  final List<T> values;
  final int page;
  final int totalCount;

  const Page(this.values, this.page, this.totalCount);
}
