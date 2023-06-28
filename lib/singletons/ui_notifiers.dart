import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class UINotifiers {
  // Singleton
  static final _instance = UINotifiers._internal();
  factory UINotifiers() => _instance;

  UINotifiers._internal() {
    isFullScreen.addListener(() async {
      windowManager.setFullScreen(isFullScreen.value);

      // HACK: exit full screen makes layout a mass in Windows
      if (isFullScreen.value == false) {
        var size = await windowManager.getSize();
        size += const Offset(1, 1);
        windowManager.setSize(size);
      }
    });
  }

  final isFullScreen = ValueNotifier<bool>(false);
  final isUIHidden = ValueNotifier<bool>(false);
  final isBusy = ValueNotifier<bool>(false);
  final hintText = ValueNotifier<String?>(null);
}
