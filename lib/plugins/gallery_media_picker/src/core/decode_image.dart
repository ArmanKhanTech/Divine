// ignore_for_file: deprecated_member_use
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class DecodeImage extends ImageProvider<DecodeImage> {
  final AssetPathEntity entity;

  final double scale;

  final int thumbSize;
  final int index;

  const DecodeImage(
    this.entity, {
    this.scale = 1.0,
    this.thumbSize = 200,
    this.index = 0,
  });

  ImageStreamCompleter load(DecodeImage key) {
    return MultiFrameImageStreamCompleter(
      codec: loadAsync(key),
      scale: key.scale,
    );
  }

  Future<Codec> loadAsync(DecodeImage key) async {
    assert(key == this);
    final coverEntity =
        (await key.entity.getAssetListRange(start: index, end: index + 1))[0];
    final bytes = await coverEntity
        .thumbnailDataWithSize(ThumbnailSize(thumbSize, thumbSize));

    return await instantiateImageCodec(bytes!);
  }

  @override
  Future<DecodeImage> obtainKey(ImageConfiguration configuration) async {
    return this;
  }
}
