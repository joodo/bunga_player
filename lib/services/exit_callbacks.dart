import 'package:window_manager/window_manager.dart';

typedef ExitCallback = Future<void> Function();

// HACK: AppLifecycleListener.onExitRequested not work on Windows
class ExitCallbacks with WindowListener {
  ExitCallbacks() {
    windowManager.setPreventClose(true);
    windowManager.addListener(this);
  }

  final _callbacks = <ExitCallback>[];

  void add(ExitCallback callback) => _callbacks.add(callback);

  Future<void> runAll() async {}

  @override
  void onWindowClose() async {
    for (final callback in _callbacks) {
      await callback();
    }
    await windowManager.destroy();
  }
}
