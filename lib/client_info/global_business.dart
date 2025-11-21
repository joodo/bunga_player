import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/utils/business/generate_username.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/generate_password.dart';

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
      const Uuid().v4(),
    );
    return MultiProvider(
      providers: [
        ValueListenableProvider.value(
          value: ValueNotifier(
            ClientAccount(
              id: clientId,
              password: getIt<Preferences>().getOrCreate(
                'client_pwd',
                generatePassword(),
              ),
            ),
          )..watchInConsole('Client Account'),
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
