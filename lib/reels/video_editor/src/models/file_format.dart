class FileFormat {
  const FileFormat(this.extension);

  final String extension;
}

class VideoExportFormat extends FileFormat {
  const VideoExportFormat(super.extension);

  static const avi = VideoExportFormat('avi');
  static const gif = GifExportFormat();
  static const mov = VideoExportFormat('mov');
  static const mp4 = VideoExportFormat('mp4');
}

class GifExportFormat extends VideoExportFormat {
  const GifExportFormat({this.fps = 10}) : super('gif');

  final int fps;
}

class CoverExportFormat extends FileFormat {
  const CoverExportFormat(super.extension);

  static const jpg = CoverExportFormat('jpg');
  static const png = CoverExportFormat('png');
  static const webp = CoverExportFormat('webp');
}
