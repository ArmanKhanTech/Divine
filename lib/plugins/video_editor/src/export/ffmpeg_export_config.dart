// ignore_for_file: unnecessary_string_escapes
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../utilities/controller.dart';
import '../models/file_format.dart';

class FFmpegVideoEditorExecute {
  const FFmpegVideoEditorExecute({
    required this.command,
    required this.outputPath,
  });

  final String command;
  final String outputPath;
}

abstract class FFmpegVideoEditorConfig {
  final VideoEditorController controller;

  final String? name;
  final String? outputDirectory;

  final double scale;

  final bool isFiltersEnabled;

  const FFmpegVideoEditorConfig(
    this.controller, {
    this.name,
    @protected this.outputDirectory,
    this.scale = 1.0,
    this.isFiltersEnabled = true,
  });

  String get cropCmd {
    if (controller.minCrop <= minOffset && controller.maxCrop >= maxOffset) {
      return "";
    }

    final enddx = controller.videoWidth * controller.maxCrop.dx;
    final enddy = controller.videoHeight * controller.maxCrop.dy;
    final startdx = controller.videoWidth * controller.minCrop.dx;
    final startdy = controller.videoHeight * controller.minCrop.dy;

    return "crop=${enddx - startdx}:${enddy - startdy}:$startdx:$startdy";
  }

  String get rotationCmd {
    final count = controller.rotation / 90;
    if (count <= 0 || count >= 4) return "";

    final List<String> transpose = [];
    for (int i = 0; i < controller.rotation / 90; i++) {
      transpose.add("transpose=2");
    }

    return transpose.isNotEmpty ? transpose.join(',') : "";
  }

  String get scaleCmd => scale == 1.0 ? "" : "scale=iw*$scale:ih*$scale";

  List<String> getExportFilters() {
    if (!isFiltersEnabled) return [];
    final List<String> filters = [cropCmd, scaleCmd, rotationCmd];
    filters.removeWhere((item) => item.isEmpty);

    return filters;
  }

  String filtersCmd(List<String> filters) {
    filters.removeWhere((item) => item.isEmpty);

    return filters.isNotEmpty ? "-vf '${filters.join(",")}'" : "";
  }

  Future<String> getOutputPath({
    required String filePath,
    required FileFormat format,
  }) async {
    final String tempPath =
        outputDirectory ?? (await getTemporaryDirectory()).path;
    final String n = name ?? path.basenameWithoutExtension(filePath);
    final int epoch = DateTime.now().millisecondsSinceEpoch;

    return "$tempPath/${n}_$epoch.${format.extension}";
  }

  double getFFmpegProgress(int time) {
    final double progressValue =
        time / controller.trimmedDuration.inMilliseconds;

    return progressValue.clamp(0.0, 1.0);
  }

  Future<FFmpegVideoEditorExecute?> getExecuteConfig();
}

class VideoFFmpegVideoEditorConfig extends FFmpegVideoEditorConfig {
  const VideoFFmpegVideoEditorConfig(
    super.controller, {
    super.name,
    super.outputDirectory,
    super.scale,
    super.isFiltersEnabled,
    this.format = VideoExportFormat.mp4,
    this.commandBuilder,
  });

  final VideoExportFormat format;

  final String Function(
    FFmpegVideoEditorConfig config,
    String videoPath,
    String outputPath,
  )? commandBuilder;

  String get startTrimCmd => "-ss ${controller.startTrim}";

  String get toTrimCmd => "-t ${controller.trimmedDuration}";

  String get gifCmd =>
      format.extension == VideoExportFormat.gif.extension ? "-loop 0" : "";

  @override
  List<String> getExportFilters() {
    final List<String> filters = super.getExportFilters();
    final bool isGif = format.extension == VideoExportFormat.gif.extension;
    if (isGif) {
      filters.add(
          'fps=${format is GifExportFormat ? (format as GifExportFormat).fps : VideoExportFormat.gif.fps}');
    }

    return filters;
  }

  @override
  Future<FFmpegVideoEditorExecute> getExecuteConfig() async {
    final String videoPath = controller.file.path;
    final String outputPath =
        await getOutputPath(filePath: videoPath, format: format);
    final List<String> filters = getExportFilters();

    return FFmpegVideoEditorExecute(
      command: commandBuilder != null
          ? commandBuilder!(this, "\'$videoPath\'", "\'$outputPath\'")
          : "$startTrimCmd -i \'$videoPath\' $toTrimCmd ${filtersCmd(filters)} $gifCmd ${filters.isEmpty ? '-c copy' : ''} -y \'$outputPath\'",
      outputPath: outputPath,
    );
  }
}

class CoverFFmpegVideoEditorConfig extends FFmpegVideoEditorConfig {
  const CoverFFmpegVideoEditorConfig(
    super.controller, {
    super.name,
    super.outputDirectory,
    super.scale,
    super.isFiltersEnabled,
    this.format = CoverExportFormat.jpg,
    this.quality = 100,
    this.commandBuilder,
  });

  final CoverExportFormat format;

  final int quality;

  final String Function(
    CoverFFmpegVideoEditorConfig config,
    String coverPath,
    String outputPath,
  )? commandBuilder;

  Future<String?> _generateCoverFile() async => VideoThumbnail.thumbnailFile(
        imageFormat: ImageFormat.JPEG,
        thumbnailPath: (await getTemporaryDirectory()).path,
        video: controller.file.path,
        timeMs: controller.selectedCoverVal?.timeMs ??
            controller.startTrim.inMilliseconds,
        quality: quality,
      );

  @override
  Future<FFmpegVideoEditorExecute?> getExecuteConfig() async {
    final String? coverPath = await _generateCoverFile();
    if (coverPath == null) {
      debugPrint('VideoThumbnail library error while exporting the cover');

      return null;
    }
    final String outputPath =
        await getOutputPath(filePath: coverPath, format: format);
    final List<String> filters = getExportFilters();

    return FFmpegVideoEditorExecute(
      command: commandBuilder != null
          ? commandBuilder!(this, "\'$coverPath\'", "\'$outputPath\'")
          : "-i \'$coverPath\' ${filtersCmd(filters)} -y \'$outputPath\'",
      outputPath: outputPath,
    );
  }
}
