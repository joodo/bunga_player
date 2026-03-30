import 'package:flutter/foundation.dart';

import '/preferences/preferences.dart';
import '/services/services.dart';

import 'model.dart';

class VolumeNotifier extends ValueNotifier<Volume> {
  final String preferenceKey;
  VolumeNotifier({required this.preferenceKey}) : super(Volume.max);

  void forward(double offset) {
    value = Volume(level: value.level + offset);
  }

  void loadFromPref() {
    final level = getIt<Preferences>().get<double>(preferenceKey);
    if (level != null) value = Volume(level: level);
  }

  void saveToPref() {
    getIt<Preferences>().set(preferenceKey, value.level);
  }
}
