import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/foundation.dart';

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
