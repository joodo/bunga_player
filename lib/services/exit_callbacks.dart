import 'dart:io';

import 'package:window_manager/window_manager.dart';

typedef ExitCallback = Future<void> Function();

class ExitCallbacks with WindowListener {
  ExitCallbacks() {
    if (Platform.isMacOS || Platform.isWindows) {
      windowManager.setPreventClose(true);
      windowManager.addListener(this);
    } else {
      // TODO: exit call for ios
    }
  }

  final _callbacks = <ExitCallback>[];
  void add(ExitCallback callback) => _callbacks.add(callback);
  bool remove(ExitCallback callback) => _callbacks.remove(callback);
  Future<void> _runAll() async {
    for (final callback in _callbacks) {
      await callback();
    }
  }

  ExitCallback? _shutter;
  void setShutter(ExitCallback shutter) => _shutter = shutter;

  // HACK: AppLifecycleListener.onExitRequested not work on Windows
  @override
  void onWindowClose() async {
    await Future.any([
      _runAll(),
      if (_shutter != null) _shutter!.call(),
    ]);
    await windowManager.destroy();
  }
}
