import 'package:flutter/material.dart';
import 'package:nanoid_plus/nanoid_plus.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '/console/service.dart';
import '/preferences/preferences.dart';
import '/services/services.dart';
import '/utils/generate_password.dart';
import '/utils/generate_username.dart';

import 'models/client_account.dart';

class ClientNicknameNotifier extends ValueNotifier<String> {
  ClientNicknameNotifier(super.defaultName) {
    bindPreference<String>(
      key: 'user_name',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class ClientColorHueNotifier extends ValueNotifier<int> {
  ClientColorHueNotifier(super._value) {
    bindPreference<int>(
      key: 'color_hue',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class ClientInfoGlobalBusiness extends SingleChildStatelessWidget {
  const ClientInfoGlobalBusiness({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final clientId = getIt<Preferences>().getOrCreate(
      'client_id',
      Nanoid().urlSafe(length: 8),
    );
    final password = getIt<Preferences>().getOrCreate(
      'client_pwd',
      generatePassword(),
    );
    return MultiProvider(
      providers: [
        ValueListenableProvider.value(
          value: ValueNotifier(ClientAccount(id: clientId, password: password))
            ..watchInConsole('Client Account'),
        ),
        ChangeNotifierProxyProvider<ClientAccount, ClientColorHueNotifier?>(
          create: (context) => null,
          update: (context, cliendAccount, previous) {
            if (previous == null) {
              return ClientColorHueNotifier(cliendAccount.id.hashCode % 360);
            } else {
              return previous;
            }
          },
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ClientNicknameNotifier(generateUsername(clientId)),
          lazy: false,
        ),
      ],
      child: child,
    );
  }
}
