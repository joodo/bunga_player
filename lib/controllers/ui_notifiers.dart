import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class UINotifiers {
  // Singleton
  static final _instance = UINotifiers._internal();
  factory UINotifiers() => _instance;

  UINotifiers._internal() {
    isFullScreen.addListener(() async {
      windowManager.setFullScreen(isFullScreen.value);
    });
  }

  final isFullScreen = ValueNotifier<bool>(false);
  final isUIHidden = ValueNotifier<bool>(false);
  final isBusy = ValueNotifier<bool>(true);
  final hintText = ValueNotifier<String?>('...');
}
