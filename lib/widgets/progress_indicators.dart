import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Progress bar widgets.
Center circularProgress(context, Color color) {
  return Center(
    child: SpinKitSpinningLines(
      size: 50.0,
      color: color,
    ),
  );
}
