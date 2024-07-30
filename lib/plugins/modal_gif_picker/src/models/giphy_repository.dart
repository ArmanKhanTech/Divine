import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:divine/plugins/modal_gif_picker/src/models/repository.dart';
import 'package:http/http.dart' as http;

import '../../modal_gif_picker.dart';
import '../widgets/giphy_render_image.dart';

import 'client/client.dart';
import 'client/collection.dart';
import 'client/gif.dart';
import 'client/languages.dart';
import 'client/rating.dart';
import 'giphy_preview_types.dart';

typedef GetCollection = Future<GiphyCollection> Function(
    GiphyClient client, int offset, int limit);

class GiphyRepository extends Repository<GiphyGif> {
  final _client = http.Client();

  final _previewCompleters = HashMap<int, Completer<Uint8List?>>();

  final _previewQueue = Queue<int>();

  final GetCollection getCollection;

  final int maxConcurrentPreviewLoad;

  late GiphyClient _giphyClient;

  int _previewLoad = 0;

  final GiphyPreviewType? previewType;

  GiphyRepository({
    required String apiKey,
    required this.getCollection,
    this.maxConcurrentPreviewLoad = 4,
    int pageSize = 25,
    ErrorListener? onError,
    this.previewType,
  }) : super(pageSize: pageSize, onError: onError) {
    _giphyClient = GiphyClient(apiKey: apiKey, client: _client);
  }

  @override
  Future<Page<GiphyGif>> getPage(int page) async {
    final offset = page * pageSize;
    final collection = await getCollection(_giphyClient, offset, pageSize);

    return Page(collection.data, page, collection.pagination?.totalCount ?? 0);
  }

  Future<Uint8List?> getPreview(int index) async {
    var completer = _previewCompleters[index];
    if (completer == null) {
      completer = Completer<Uint8List?>();
      _previewCompleters[index] = completer;
      _previewQueue.add(index);
      _loadNextPreview();
    }

    return completer.future;
  }

  void cancelGetPreview(int index) {
    final completer = _previewCompleters.remove(index);
    if (completer != null) {
      _previewQueue.remove(index);
      completer.complete(null);
    }
  }

  void _loadNextPreview() {
    if (_previewLoad < maxConcurrentPreviewLoad && _previewQueue.isNotEmpty) {
      _previewLoad++;

      final index = _previewQueue.removeLast();
      final completer = _previewCompleters.remove(index);
      if (completer != null) {
        get(index).then(_loadPreviewImage).then((bytes) {
          if (!completer.isCompleted) {
            completer.complete(bytes);
          }
        }).whenComplete(() {
          _previewLoad--;
          _loadNextPreview();
        });
      } else {
        _previewLoad--;
      }
      _loadNextPreview();
    }
  }

  Future<Uint8List?> _loadPreviewImage(GiphyGif gif) async {
    String? url;
    switch (previewType) {
      case GiphyPreviewType.fixedWidthSmallStill:
        url = gif.images.fixedWidthSmallStill?.url;
        break;
      case GiphyPreviewType.previewGif:
        url = gif.images.previewGif?.url;
        break;
      case GiphyPreviewType.fixedHeight:
        url = gif.images.fixedHeight?.url;
        break;
      case GiphyPreviewType.original:
        url = gif.images.original?.url;
        break;
      case GiphyPreviewType.previewWebp:
        url = gif.images.previewWebp?.url;
        break;
      case GiphyPreviewType.downsizedLarge:
        url = gif.images.downsizedLarge?.url;
        break;
      case GiphyPreviewType.originalStill:
        url = gif.images.originalStill?.url;
        break;
      default:
        url = null;
        break;
    }
    url ??= gif.images.previewGif?.url ??
        gif.images.fixedWidthSmallStill?.url ??
        gif.images.fixedHeightDownsampled?.url ??
        gif.images.original?.url;

    if (url != null) {
      return await GiphyRenderImage.load(url, client: _client);
    }

    return null;
  }

  static Future<GiphyRepository> trending({
    required String apiKey,
    String rating = GiphyRating.g,
    bool sticker = false,
    ErrorListener? onError,
    GiphyPreviewType? previewType,
  }) async {
    final repo = GiphyRepository(
        apiKey: apiKey,
        previewType: previewType,
        getCollection: (client, offset, limit) => client.trending(
            offset: offset, limit: limit, rating: rating, sticker: sticker),
        onError: onError);
    await repo.get(0);

    return repo;
  }

  static Future<GiphyRepository> search(
      {required String apiKey,
      required String query,
      String rating = GiphyRating.g,
      String lang = GiphyLanguage.english,
      bool sticker = false,
      GiphyPreviewType? previewType,
      ErrorListener? onError}) async {
    final repo = GiphyRepository(
        apiKey: apiKey,
        previewType: previewType,
        getCollection: (client, offset, limit) => client.search(query,
            offset: offset,
            limit: limit,
            rating: rating,
            lang: lang,
            sticker: sticker),
        onError: onError);
    await repo.get(0);

    return repo;
  }
}
