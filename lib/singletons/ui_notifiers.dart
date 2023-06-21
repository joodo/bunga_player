import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class UINotifiers {
  // Singleton
  static final _instance = UINotifiers._internal();
  factory UINotifiers() => _instance;

  UINotifiers._internal() {
    isFullScreen
        .addListener(() => windowManager.setFullScreen(isFullScreen.value));
  }

  final isFullScreen = ValueNotifier<bool>(false);
  final isUIHidden = ValueNotifier<bool>(false);
  final isBusy = ValueNotifier<bool>(false);
  final hintText = ValueNotifier<String?>(null);
}
