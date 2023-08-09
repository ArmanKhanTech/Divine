import 'dart:io';
import 'package:divine/reels/video_editor/src/utilities/helpers.dart';
import 'package:divine/reels/video_editor/src/utilities/thumbnails.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'models/cover_data.dart';
import 'models/cover_style.dart';
import 'models/crop_style.dart';
import 'models/trim_style.dart';

class VideoMinDurationError extends Error {
  final Duration minDuration;
  final Duration videoDuration;

  VideoMinDurationError(this.minDuration, this.videoDuration);

  @override
  String toString() =>
      "Invalid argument (minDuration): The minimum duration ($minDuration) cannot be bigger than the duration of the video file ($videoDuration)";
}

enum RotateDirection { left, right }

const Offset maxOffset = Offset(1.0, 1.0);
const Offset minOffset = Offset.zero;

class VideoEditorController extends ChangeNotifier {
  final TrimSliderStyle trimStyle;

  final CoverSelectionStyle coverStyle;

  final CropGridStyle cropStyle;

  final File file;

  VideoEditorController.file(
    this.file, {
    this.maxDuration = Duration.zero,
    this.minDuration = Duration.zero,
    this.coverThumbnailsQuality = 10,
    this.trimThumbnailsQuality = 10,
    this.coverStyle = const CoverSelectionStyle(),
    this.cropStyle = const CropGridStyle(),
    TrimSliderStyle? trimStyle,
  })  : _video = VideoPlayerController.file(File(
          Platform.isIOS ? Uri.encodeFull(file.path) : file.path,
        )),
        trimStyle = trimStyle ?? TrimSliderStyle(),
        assert(maxDuration > minDuration,
            'The maximum duration must be bigger than the minimum duration.');

  int _rotation = 0;

  bool _isTrimming = false;
  bool _isTrimmed = false;
  bool isCropping = false;

  double? _preferredCropAspectRatio;

  double _minTrim = minOffset.dx;
  double _maxTrim = maxOffset.dx;

  double textx1 = 100;
  double texty1 = 100;

  double textx1Prev = 100;
  double texty1Prev = 100;

  late String text;

  TextAlign textAlign = TextAlign.left;

  Color textColor = Colors.white;
  Color textBgColor = Colors.transparent;

  double textSize = 25;

  bool textOverlay = false;

  Offset _minCrop = minOffset;
  Offset _maxCrop = maxOffset;

  Offset cacheMinCrop = minOffset;
  Offset cacheMaxCrop = maxOffset;

  Duration _trimEnd = Duration.zero;
  Duration _trimStart = Duration.zero;

  final VideoPlayerController _video;

  final ValueNotifier<CoverData?> _selectedCover =
      ValueNotifier<CoverData?>(null);

  VideoPlayerController get video => _video;

  bool get initialized => _video.value.isInitialized;
  bool get isPlaying => _video.value.isPlaying;

  Duration get videoPosition => _video.value.position;
  Duration get videoDuration => _video.value.duration;

  Size get videoDimension => _video.value.size;

  double get videoWidth => videoDimension.width;
  double get videoHeight => videoDimension.height;
  double get minTrim => _minTrim;
  double get maxTrim => _maxTrim;

  double get textx1Value => textx1;
  double get texty1Value => texty1;

  double get textx1PrevValue => textx1Prev;
  double get texty1PrevValue => texty1Prev;

  String get textValue => text;

  TextAlign get textAlignValue => textAlign;

  Color get textColorValue => textColor;
  Color get textBgColorValue => textBgColor;

  bool get textOverlayValue => textOverlay;

  void setTextx1(double value) {
    textx1 = value + textx1Prev;
    notifyListeners();
  }

  void setTexty1(double value) {
    texty1 = value + texty1Prev;
    notifyListeners();
  }

  void setText(String value) {
    text = value;
    notifyListeners();
  }

  void setTextOverlay(bool value) {
    textOverlay = value;
    notifyListeners();
  }

  void setTextBgColor(Color value) {
    textBgColor = value;
    notifyListeners();
  }

  void setTextColor(Color value) {
    textColor = value;
    notifyListeners();
  }

  void setTextSize(double value) {
    textSize = value;
    notifyListeners();
  }

  void setTextAlign(TextAlign value) {
    textAlign = value;
    notifyListeners();
  }

  Duration get startTrim => _trimStart;
  Duration get endTrim => _trimEnd;
  Duration get trimmedDuration => endTrim - startTrim;

  Offset get minCrop => _minCrop;
  Offset get maxCrop => _maxCrop;

  Size get croppedArea => Rect.fromLTWH(
        0,
        0,
        videoWidth * (maxCrop.dx - minCrop.dx),
        videoHeight * (maxCrop.dy - minCrop.dy),
      ).size;

  double? get preferredCropAspectRatio => _preferredCropAspectRatio;
  set preferredCropAspectRatio(double? value) {
    if (preferredCropAspectRatio == value) return;
    _preferredCropAspectRatio = value;
    notifyListeners();
  }

  void setPreferredRatioFromCrop() {
    _preferredCropAspectRatio = croppedArea.aspectRatio;
    notifyListeners();
  }

  void cropAspectRatio(double? value) {
    preferredCropAspectRatio = value;

    if (value != null) {
      final newSize = computeSizeWithRatio(videoDimension, value);

      Rect centerCrop = Rect.fromCenter(
        center: Offset(videoWidth / 2, videoHeight / 2),
        width: newSize.width,
        height: newSize.height,
      );

      _minCrop =
          Offset(centerCrop.left / videoWidth, centerCrop.top / videoHeight);
      _maxCrop = Offset(
          centerCrop.right / videoWidth, centerCrop.bottom / videoHeight);
      notifyListeners();
    }
  }

  Future<void> initialize({double? aspectRatio}) async {
    await _video.initialize();

    if (minDuration > videoDuration) {
      throw VideoMinDurationError(minDuration, videoDuration);
    }

    _video.addListener(_videoListener);
    _video.setLooping(true);

    maxDuration = maxDuration == Duration.zero ? videoDuration : maxDuration;

    if (maxDuration < videoDuration) {
      updateTrim(
          0.0, maxDuration.inMilliseconds / videoDuration.inMilliseconds);
    } else {
      _updateTrimRange();
    }

    cropAspectRatio(aspectRatio);
    generateDefaultCoverThumbnail();

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    if (_video.value.isPlaying) await _video.pause();
    _video.removeListener(_videoListener);
    _video.dispose();
    _selectedCover.dispose();
    super.dispose();
  }

  void _videoListener() {
    final position = videoPosition;
    if (position < _trimStart || position > _trimEnd) {
      _video.seekTo(_trimStart);
    }
  }

  void applyCacheCrop() => updateCrop(cacheMinCrop, cacheMaxCrop);
  void updateCrop(Offset min, Offset max) {
    assert(min < max,
        'Minimum crop value ($min) cannot be bigger and maximum crop value ($max)');

    _minCrop = min;
    _maxCrop = max;
    notifyListeners();
  }

  void updateTrim(double min, double max) {
    assert(min < max,
        'Minimum trim value ($min) cannot be bigger and maximum trim value ($max)');

    final double newDuration = videoDuration.inMicroseconds * (max - min);

    final Duration newDurationCeil = Duration(microseconds: newDuration.ceil());
    final Duration newDurationFloor =
        Duration(microseconds: newDuration.floor());
    assert(newDurationFloor <= maxDuration,
        'Trim duration ($newDurationFloor) cannot be smaller than $minDuration');
    assert(newDurationCeil >= minDuration,
        'Trim duration ($newDurationCeil) cannot be bigger than $maxDuration');

    _minTrim = min;
    _maxTrim = max;
    _updateTrimRange();
  }

  void _updateTrimRange() {
    _trimStart = videoDuration * minTrim;
    _trimEnd = videoDuration * maxTrim;

    if (_trimStart != Duration.zero || _trimEnd != videoDuration) {
      _isTrimmed = true;
    } else {
      _isTrimmed = false;
    }

    _checkUpdateDefaultCover();

    notifyListeners();
  }

  bool get isTrimmed => _isTrimmed;
  bool get isTrimming => _isTrimming;
  set isTrimming(bool value) {
    _isTrimming = value;
    if (!value) {
      _checkUpdateDefaultCover();
    }
    notifyListeners();
  }

  Duration maxDuration;
  final Duration minDuration;

  double get trimPosition =>
      videoPosition.inMilliseconds / videoDuration.inMilliseconds;

  final int coverThumbnailsQuality;
  final int trimThumbnailsQuality;

  void updateSelectedCover(CoverData selectedCover) async {
    _selectedCover.value = selectedCover;
  }

  void _checkUpdateDefaultCover() {
    if (!_isTrimming || _selectedCover.value == null) {
      updateSelectedCover(CoverData(timeMs: startTrim.inMilliseconds));
    }
  }

  void generateDefaultCoverThumbnail() async {
    final defaultCover = await generateSingleCoverThumbnail(
      file.path,
      timeMs: startTrim.inMilliseconds,
      quality: coverThumbnailsQuality,
    );
    updateSelectedCover(defaultCover);
  }

  ValueNotifier<CoverData?> get selectedCoverNotifier => _selectedCover;

  CoverData? get selectedCoverVal => _selectedCover.value;

  int get cacheRotation => _rotation;
  int get rotation => (_rotation ~/ 90 % 4) * 90;

  void rotate90Degrees([RotateDirection direction = RotateDirection.right]) {
    switch (direction) {
      case RotateDirection.left:
        _rotation += 90;
        break;
      case RotateDirection.right:
        _rotation -= 90;
        break;
    }
    notifyListeners();
  }

  bool get isRotated => rotation == 90 || rotation == 270;
}
