import 'package:bunga_player/services/logger.dart';
import 'package:flutter/widgets.dart';

import 'package:bunga_player/utils/business/platform.dart';

typedef PresenceCallback = Future<void> Function();

class PresenceCallbacks {
  late final AppLifecycleListener listener;
  PresenceCallbacks() {
    listener = !kIsDesktop
        ? AppLifecycleListener(onHide: _runAll)
        : AppLifecycleListener(
            onExitRequested: () async {
              await Future.any([_runAll(), _shutter()]);
              return .exit;
            },
          );
  }

  final _callbacks = <PresenceCallback>[];
  void add(PresenceCallback callback) => _callbacks.add(callback);
  bool remove(PresenceCallback callback) => _callbacks.remove(callback);
  Future<void> _runAll() async {
    for (final callback in _callbacks) {
      await callback();
    }
    logger.i('Finish presence callbacks.');
  }

  Future<void> _shutter() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    logger.w('Too long, force shut down.');
  }
}
