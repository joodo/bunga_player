import 'package:bunga_player/models/playing/volume.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/services/network.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
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

class SettingGithubProxy extends ValueNotifier<String> {
  SettingGithubProxy() : super('') {
    bindPreference<String>(
      preferences: getIt<Preferences>(),
      key: 'github_proxy',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

final settingProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => SettingProxy(), lazy: false),
    ChangeNotifierProvider(create: (context) => SettingGithubProxy()),
    ChangeNotifierProvider(
        create: (context) => SettingBungaHost(), lazy: false),
    ChangeNotifierProvider(create: (context) => SettingClientId(), lazy: false),
    ChangeNotifierProvider(create: (context) => SettingUserName(), lazy: false),
    ChangeNotifierProvider(create: (context) => SettingCallVolume()),
    ChangeNotifierProvider(
        create: (context) => SettingCallNoiseSuppressionLevel()),
  ],
);
