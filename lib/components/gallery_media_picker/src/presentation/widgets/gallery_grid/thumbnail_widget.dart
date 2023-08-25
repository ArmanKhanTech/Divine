import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../core/decode_image.dart';
import '../../pages/gallery_media_picker_controller.dart';

class ThumbnailWidget extends StatefulWidget{
  final AssetEntity asset;

  final int index;

  final GalleryMediaPickerController provider;

  const ThumbnailWidget(
      {Key? key,
        required this.index,
        required this.asset,
        required this.provider
      }) : super(key: key);

  @override
  State<ThumbnailWidget> createState() => ThumbnailWidgetState();

}

class ThumbnailWidgetState extends State<ThumbnailWidget> {
  late Color topLeftColor;
  late Color bottomRightColor;

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
              color: Colors.transparent
          ),
        ),

        if (widget.asset.type == AssetType.image || widget.asset.type == AssetType.video)
          FutureBuilder<Uint8List?>(
            future: widget.asset.thumbnailData,
            builder: (_, data) {
              if (data.hasData) {

                return ImagePixels(
                  imageProvider: MemoryImage(data.data!),
                  builder: (BuildContext context, ImgDetails img) {
                    topLeftColor = img.pixelColorAtAlignment!(Alignment.topLeft);
                    bottomRightColor = img.pixelColorAtAlignment!(Alignment.bottomRight);

                    return Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                topLeftColor, bottomRightColor
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image(
                            image: DecodeImage(
                                widget.provider.pathList[widget.provider.pathList.indexOf(widget.provider.currentAlbum!)],
                                thumbSize: 200,
                                index: widget.index
                            ),
                            gaplessPlayback: true,
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.high,
                          ),
                        )
                    );
                  },
                );
              } else {

                return const Icon(
                  Icons.error,
                  color: Colors.grey,
                  size: 30,
                );
              }
            },
          ),

        AnimatedBuilder(
            animation: widget.provider,
            builder: (_, __) {
              final pickIndex = widget.provider.pickIndex(widget.asset);
              final picked = pickIndex >= 0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: picked
                      ? widget.provider.paramsModel.selectedBackgroundColor
                          .withOpacity(0.3)
                      : Colors.transparent,
                ),
              );
            }),

        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 5, top: 5),
            child: AnimatedBuilder(
                animation: widget.provider,
                builder: (_, __) {
                  final pickIndex = widget.provider.pickIndex(widget.asset);
                  final picked = pickIndex >= 0;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: picked ? 1 : 0,
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: picked
                            ? widget.provider.paramsModel.selectedCheckBackgroundColor
                                .withOpacity(0.6)
                            : Colors.transparent,
                        border: Border.all(
                            width: 1.5,
                            color: widget.provider.paramsModel.selectedCheckColor),
                      ),
                      child: Icon(
                        Icons.check,
                        color: widget.provider.paramsModel.selectedCheckColor,
                        size: 14,
                      ),
                    ),
                  );
                }),
          ),
        ),

        if (widget.asset.type == AssetType.video)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1)),
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        parseDuration(widget.asset.videoDuration.inSeconds),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 8
                        ),
                      ),
                    ],
                  )),
            ),
          )
      ],
    );
  }
}

parseDuration(int seconds) {
  if (seconds < 600) {

    return '${Duration(seconds: seconds)}'.toString().substring(3, 7);
  } else if (seconds > 600 && seconds < 3599) {

    return '${Duration(seconds: seconds)}'.toString().substring(2, 7);
  } else {

    return '${Duration(seconds: seconds)}'.toString().substring(1, 7);
  }
}
