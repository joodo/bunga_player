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
    bindPreference<String>(
      preferences: getIt<Preferences>(),
      key: 'client_id',
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

final settingProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => SettingProxy(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => SettingBungaHost(), lazy: false),
    ChangeNotifierProvider(create: (context) => SettingClientId(), lazy: false),
    ChangeNotifierProvider(create: (context) => SettingUserName(), lazy: false),
  ],
);
