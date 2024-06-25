import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget cachedImage(String imgUrl) {
  return CachedNetworkImage(
    imageUrl: imgUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) {
      return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surface == Colors.white
            ? Colors.grey[300]!
            : Colors.grey[700]!,
        highlightColor: Theme.of(context).colorScheme.surface == Colors.white
            ? Colors.grey[100]!
            : Colors.grey[800]!,
        child: Container(
          height: 100,
          width: 150,
          color: Theme.of(context).colorScheme.surface == Colors.white
              ? Colors.grey[300]!
              : Colors.grey[700]!,
        ),
      );
    },
    errorWidget: (context, url, error) => const Center(
      child: Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 30.0,
      ),
    ),
  );
}
