import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Progress bar widgets.
Center circularProgress(context) {
  return const Center(
    child: SpinKitSpinningLines(
      size: 50.0,
      color: Colors.blue,
    ),
  );
}
