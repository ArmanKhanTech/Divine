import 'package:flutter/material.dart';

class AppLifeCycleEventHandler extends WidgetsBindingObserver {
  AppLifeCycleEventHandler(
      {required this.resumeCallBack, required this.detachedCallBack});

  final Function resumeCallBack;
  final Function detachedCallBack;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await detachedCallBack();
        break;
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
    }
  }
}
