import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ClientId extends ValueNotifier<String> {
  ClientId() : super(const Uuid().v4()) {
    final pref = getIt<Preferences>();
    final prefId = pref.get<String>('client_id');
    if (prefId == null) {
      pref.set('client_id', value);
    } else {
      value = prefId;
    }
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

class ClientUserName extends ValueNotifier<String> {
  ClientUserName() : super('') {
    bindPreference<String>(
      preferences: getIt<Preferences>(),
      key: 'user_name',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

final clientInfoProviders = MultiProvider(
  providers: [
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
    ChangeNotifierProvider(create: (context) => ClientUserName(), lazy: false),
  ],
);
