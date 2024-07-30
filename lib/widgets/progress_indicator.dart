import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget circularProgress(context, Color color, {double size = 50.0}) {
  return Center(
    child: SpinKitFadingCircle(
      size: size,
      color: color,
    ),
  );
}
