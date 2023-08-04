import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Center circularProgress(context, Color color) {

  return Center(
    child: SpinKitFadingCircle(
      size: 50.0,
      color: color,
    ),
  );
}
