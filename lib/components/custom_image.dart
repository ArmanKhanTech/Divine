import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class CustomImage extends StatelessWidget {
  final String? imageUrl;

  final double height;
  final double width;

  final BoxFit fit;

  const CustomImage({
    super.key,
    this.imageUrl,
    this.height = 100.0,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      errorWidget: (context, url, error) {
        return const Icon(CupertinoIcons.person_crop_circle_badge_xmark);
      },
      height: height,
      width: width,
      fit: fit,
    );
  }
}