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
    this.thumbSize = 120,
    this.index = 0,
  });

  @override
  ImageStreamCompleter load(DecodeImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<Codec> loadAsync(DecodeImage key, DecoderCallback decode) async {
    assert(key == this);

    final coverEntity = (await key.entity.getAssetListRange(start: index, end: index + 1))[0];
    final bytes = await coverEntity.thumbnailDataWithSize(ThumbnailSize(thumbSize, thumbSize));

    return decode(bytes!);
  }

  @override
  Future<DecodeImage> obtainKey(ImageConfiguration configuration) async {
    return this;
  }
}
