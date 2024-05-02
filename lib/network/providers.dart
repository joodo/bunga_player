import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'service.dart';

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

final networkProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => SettingProxy(), lazy: false),
  ],
);
