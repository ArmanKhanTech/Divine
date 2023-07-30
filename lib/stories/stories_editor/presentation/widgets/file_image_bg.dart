import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_pixels/image_pixels.dart';

class FileImageBG extends StatefulWidget {
  final File filePath;

  final void Function(Color color1, Color color2) generatedGradient;

  const FileImageBG(
      {Key? key, required this.filePath, required this.generatedGradient})
      : super(key: key);

  @override
  State<FileImageBG> createState() => _FileImageBGState();
}

class _FileImageBGState extends State<FileImageBG> {
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();

  late Color topColor;
  late Color bottomColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () => widget.generatedGradient(topColor, bottomColor));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();

    return ImagePixels(
      imageProvider: FileImage(widget.filePath),
      builder: (BuildContext context, ImgDetails img) {
        topColor = img.pixelColorAtAlignment!(Alignment.topLeft);
        bottomColor = img.pixelColorAtAlignment!(Alignment.bottomRight);

        return SizedBox(
            height: screenUtil.screenHeight * 0.8,
            width: screenUtil.screenWidth * 0.8,
            child: RepaintBoundary(
                key: paintKey,
                child: Center(
                    child: Image.file(
                      File(widget.filePath.path),
                      key: imageKey,
                      filterQuality: FilterQuality.high,
                    )
                )
            )
        );
      },
    );
  }
}