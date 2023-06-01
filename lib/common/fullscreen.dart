import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class FullScreen with WindowListener {
  // Singleton
  static final _instance = FullScreen._internal();
  factory FullScreen() => _instance;

  final notifier = ValueNotifier<bool>(false);

  FullScreen._internal() {
    windowManager.addListener(this);
  }

  void dispose() {
    windowManager.removeListener(this);
  }

  @override
  void onWindowEnterFullScreen() {
    notifier.value = true;
  }

  @override
  void onWindowLeaveFullScreen() {
    notifier.value = false;
  }

  void set(bool isFullScreen) {
    windowManager.setFullScreen(isFullScreen);
  }

  void toggle() {
    set(!notifier.value);
  }
}
