import 'package:flutter/material.dart';

// This class keeps an eye on app's lifecycle events.
class AppLifeCycleEventHandler extends WidgetsBindingObserver {
  // A constructer of this class.
  AppLifeCycleEventHandler(
      {required this.resumeCallBack, required this.detachedCallBack});

  final Function resumeCallBack;
  final Function detachedCallBack;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      // If app is not in foreground or exited then :
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await detachedCallBack();
        break;
      // If app is opened or reopened again then :
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
    }
  }
}
