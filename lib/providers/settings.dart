import 'dart:convert';

import 'package:bunga_player/models/playing/volume.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/services/network.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/single_activator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class SettingProxy extends ValueNotifier<String?> {
  SettingProxy() : super(null) {
    addListener(() {
      getIt<NetworkService>().setProxy(value);
    });
    bindPreference<String>(
      preferences: getIt<Preferences>(),
      key: 'proxy',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class SettingBungaHost extends ValueNotifier<String> {
  SettingBungaHost() : super('') {
    bindPreference<String>(
      preferences: getIt<Preferences>(),
      key: 'bunga_host',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class SettingClientId extends ValueNotifier<String> {
  SettingClientId() : super(const Uuid().v4()) {
    final pref = getIt<Preferences>();
    final prefId = pref.get<String>('client_id');
    if (prefId == null) {
      pref.set('client_id', value);
    } else {
      value = prefId;
    }
  }
}

class SettingColorHue extends ValueNotifier<int> {
  SettingColorHue(super._value) {
    bindPreference<int>(
      preferences: getIt<Preferences>(),
      key: 'color_hue',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class SettingUserName extends ValueNotifier<String> {
  SettingUserName() : super('') {
    bindPreference<String>(
      preferences: getIt<Preferences>(),
      key: 'user_name',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class SettingAutoJoinChannel extends ValueNotifier<bool> {
  SettingAutoJoinChannel() : super(true) {
    bindPreference<bool>(
      preferences: getIt<Preferences>(),
      key: 'auto_join_channel',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

enum ShortcutKey {
  volumeUp,
  volumeDown,
  forward5Sec,
  backward5Sec,
  togglePlay,
  screenshot,
}

class SettingShortcutMapping
    extends ValueNotifier<Map<ShortcutKey, SingleActivator?>> {
  static const defaultMapping = {
    ShortcutKey.volumeUp: SingleActivator(LogicalKeyboardKey.arrowUp),
    ShortcutKey.volumeDown: SingleActivator(LogicalKeyboardKey.arrowDown),
    ShortcutKey.forward5Sec: SingleActivator(LogicalKeyboardKey.arrowRight),
    ShortcutKey.backward5Sec: SingleActivator(LogicalKeyboardKey.arrowLeft),
    ShortcutKey.togglePlay: SingleActivator(LogicalKeyboardKey.space),
    ShortcutKey.screenshot:
        SingleActivator(LogicalKeyboardKey.keyS, control: true),
  };

  SettingShortcutMapping() : super(defaultMapping) {
    bindPreference<String>(
      preferences: getIt<Preferences>(),
      key: 'shortcut_mapping',
      load: (pref) {
        final savedMap = (jsonDecode(pref) as Map<String, dynamic>)
            .map<String, SingleActivator?>((key, value) {
          final serialized = value as String;
          return MapEntry(
            key,
            serialized.isEmpty ? null : unserializeSingleActivator(serialized),
          );
        });
        final mergedMap = defaultMapping.map<ShortcutKey, SingleActivator?>(
          (key, value) => MapEntry(
              key, savedMap.containsKey(key.name) ? savedMap[key.name] : value),
        );
        return Map.unmodifiable(mergedMap);
      },
      update: (value) => jsonEncode(
        value.map<String, String>(
          (key, value) => MapEntry(key.name, value?.serialize() ?? ''),
        ),
      ),
    );
  }
}

class SettingCallVolume extends ValueNotifier<Volume> {
  SettingCallVolume() : super(Volume(volume: (Volume.max - Volume.min) ~/ 2)) {
    bindPreference<int>(
      preferences: getIt<Preferences>(),
      key: 'call_volume',
      load: (pref) => Volume(volume: pref),
      update: (value) => value.volume,
    );
  }
}

class SettingCallNoiseSuppressionLevel
    extends ValueNotifier<NoiseSuppressionLevel> {
  SettingCallNoiseSuppressionLevel() : super(NoiseSuppressionLevel.high);
}

final settingProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => SettingProxy(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => SettingBungaHost(), lazy: false),
    ChangeNotifierProvider(create: (context) => SettingClientId(), lazy: false),
    ChangeNotifierProxyProvider<SettingClientId, SettingColorHue?>(
      create: (context) => null,
      update: (context, cliendId, previous) {
        if (previous == null) {
          return SettingColorHue(cliendId.value.hashCode % 360);
        } else {
          return previous;
        }
      },
    ),
    ChangeNotifierProvider(create: (context) => SettingUserName(), lazy: false),
    ChangeNotifierProvider(create: (context) => SettingAutoJoinChannel()),
    ChangeNotifierProvider(create: (context) => SettingShortcutMapping()),
    ChangeNotifierProvider(create: (context) => SettingCallVolume()),
    ChangeNotifierProvider(
        create: (context) => SettingCallNoiseSuppressionLevel()),
  ],
);
