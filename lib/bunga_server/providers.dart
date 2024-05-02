import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'client.dart';

class BungaServerHost extends ValueNotifier<String> {
  BungaServerHost() : super('') {
    bindPreference<String>(
      preferences: getIt<Preferences>(),
      key: 'bunga_host',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class BungaClientNotifier extends ValueNotifier<BungaClient?> {
  BungaClientNotifier() : super(null);
}

final bungaServerProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => BungaServerHost(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => BungaClientNotifier(), lazy: false),
    ProxyProvider<BungaClientNotifier, BungaClient?>(
      update: (context, notifier, previous) => notifier.value,
    ),
  ],
);
