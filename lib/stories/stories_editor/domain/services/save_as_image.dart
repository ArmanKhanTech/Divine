import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

Future takePicture(
    {required contentKey,
      required BuildContext context,
      required saveToGallery}) async {
  try {
    RenderRepaintBoundary boundary =
    contentKey.currentContext.findRenderObject();

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final String dir = (await getApplicationDocumentsDirectory()).path;
    String imagePath = '$dir/divine${DateTime.timestamp()}.gif';
    File capturedFile = File(imagePath);
    await capturedFile.writeAsBytes(pngBytes);

    if (saveToGallery) {
      final result = await ImageGallerySaver.saveImage(pngBytes,
          quality: 100, name: "divine${DateTime.timestamp()}.gif");
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return imagePath;
    }
  } catch (e) {
    debugPrint('exception => $e');
    return false;
  }
}