import 'dart:async';

import 'package:flutter/foundation.dart';

extension WaitableListenerExtension<T> on ValueListenable<T> {
  Future<T> waitUntil(bool Function(T value) condition) async {
    final completer = Completer<T>();

    void listener() {
      if (condition(value)) {
        removeListener(listener);
        completer.complete(value);
      }
    }

    addListener(listener);

    if (condition(value)) {
      removeListener(listener);
      return value;
    }

    return completer.future;
  }
}
