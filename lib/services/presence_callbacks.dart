import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/business/platform.dart';

typedef PresenceCallback = Future<void> Function();

class PresenceCallbacks {
  late final AppLifecycleListener listener;
  PresenceCallbacks() {
    listener = !kIsDesktop
        ? AppLifecycleListener(onPause: doPresence)
        : AppLifecycleListener(
            onExitRequested: () async {
              await doPresence();
              return .exit;
            },
          );
  }

  Future<void> doPresence() async {
    try {
      await _runAll().timeout(const Duration(milliseconds: 1500));
    } on TimeoutException catch (_) {
      logger.w('Too long, force shut down.');
    } catch (e) {
      logger.w('Presence failed: $e');
    }
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
}
