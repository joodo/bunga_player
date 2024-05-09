import 'package:window_manager/window_manager.dart';

typedef ExitCallback = Future<void> Function();

class ExitCallbacks with WindowListener {
  ExitCallbacks() {
    windowManager.setPreventClose(true);
    windowManager.addListener(this);
  }

  final _callbacks = <ExitCallback>[];
  void add(ExitCallback callback) => _callbacks.add(callback);
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
