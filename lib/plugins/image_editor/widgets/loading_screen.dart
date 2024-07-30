import 'package:divine/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';

class LoadingScreen {
  final GlobalKey globalKey;

  LoadingScreen(this.globalKey);

  show([String? text]) {
    if (globalKey.currentContext == null) {
      return;
    }

    showDialog<String>(
        context: globalKey.currentContext!,
        builder: (BuildContext context) => Scaffold(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
              body: Center(
                child: circularProgress(
                  context,
                  const Color(0XFF03A9F4),
                ),
              ),
            ));
  }

  void hide() {
    if (globalKey.currentContext == null) {
      return;
    }

    Navigator.pop(globalKey.currentContext!);
  }
}
