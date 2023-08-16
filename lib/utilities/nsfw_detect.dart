/*
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class NSFWDetector {
  static const _threshold = 0.7;

  static Future<bool> detect({
    required String path,
    double threshold = _threshold,
  }) async {
    try {
      final inputImage = InputImage.fromFilePath(path);

      //final modelPath = await _getModel('assets/model/nude.tflite');

      final options = LocalLabelerOptions(
        modelPath: 'assets/model/nude.tflite',
        confidenceThreshold: threshold,
      );

      final imageLabeler = ImageLabeler(options: options);

      final imageLabels = await imageLabeler.processImage(inputImage);

      if (imageLabels.isEmpty) return false;

      final label = imageLabels.first;
      switch (label.index) {
        case 0:

          return label.confidence < threshold;
        case 1:

          return label.confidence > threshold;
        default:

          return false;
      }
    } catch (e) {
      if (kDebugMode) {
        log('flutter_nude_detector throwing error!', error: e);
      }

      return false;
    }
  }

    */
/*static Future<String?> _getModel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? modelPath = prefs.getString('modelPath');

    if(modelPath == null){
      FirebaseModelDownloader.instance
          .getModel(
          "NSFWDetector",
          FirebaseModelDownloadType.localModel,
          FirebaseModelDownloadConditions(
            iosAllowsCellularAccess: true,
            iosAllowsBackgroundDownloading: false,
            androidChargingRequired: false,
            androidWifiRequired: false,
            androidDeviceIdleRequired: false,
          )
      ).then((customModel) async {
        final localModelPath = customModel.file;
        await prefs.setString('modelPath', localModelPath.path);
        print('Model path: ${localModelPath.path}');

        return localModelPath.path;
      });
    }

    return modelPath;
  }*//*

}*/
