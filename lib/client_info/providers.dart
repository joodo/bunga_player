import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/generate_password.dart';

import 'models/client_account.dart';

class ClientId extends ValueNotifier<String> {
  ClientId()
      : super(getIt<Preferences>().getOrCreate(
          'client_id',
          const Uuid().v4(),
        ));
}

class ClientNicknameNotifier extends ValueNotifier<String> {
  ClientNicknameNotifier() : super('') {
    bindPreference<String>(
      preferences: getIt<Preferences>(),
      key: 'user_name',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class ClientColorHue extends ValueNotifier<int> {
  ClientColorHue(super._value) {
    bindPreference<int>(
      preferences: getIt<Preferences>(),
      key: 'color_hue',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

final clientInfoProviders = MultiProvider(
  providers: [
    Provider(
      create: (context) => ClientAccount(
        id: getIt<Preferences>().getOrCreate(
          'client_id',
          const Uuid().v4(),
        ),
        password: getIt<Preferences>().getOrCreate(
          'client_pwd',
          generatePassword(),
        ),
      ),
      lazy: false,
    ),
    ChangeNotifierProvider(create: (context) => ClientId(), lazy: false),
    ChangeNotifierProxyProvider<ClientId, ClientColorHue?>(
      create: (context) => null,
      update: (context, cliendId, previous) {
        if (previous == null) {
          return ClientColorHue(cliendId.value.hashCode % 360);
        } else {
          return previous;
        }
      },
    ),
    ChangeNotifierProvider(
        create: (context) => ClientNicknameNotifier(), lazy: false),
  ],
);
