import 'package:flutter/foundation.dart';

import '/services/services.dart';

import 'service.dart';

ValueNotifier<T> createPreferenceNotifier<T>({
  required String key,
  required T initValue,
}) {
  final pref = getIt<Preferences>();
  final notifier = ValueNotifier<T>(pref.get<T>(key) ?? initValue);
  notifier.addListener(() {
    pref.set(key, notifier.value);
  });
  return notifier;
}

extension BindPreference<R> on ValueNotifier<R> {
  void bindPreference<T>({
    required String key,
    required R Function(T pref) load,
    required T? Function(R value) update,
  }) {
    final pref = getIt<Preferences>();

    final prefValue = pref.get<T>(key);
    if (prefValue != null) {
      value = load(prefValue);
    }

    addListener(() {
      pref.set(key, update(value));
    });
  }
}
