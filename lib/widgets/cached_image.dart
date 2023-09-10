import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget cachedImage(String imgUrl) {

  return CachedNetworkImage(
    imageUrl: imgUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) {

      return Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Theme.of(context).colorScheme.secondary,
        child: const SizedBox(),
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