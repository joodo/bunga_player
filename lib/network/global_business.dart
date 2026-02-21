import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'service.dart';

class SettingProxy extends ValueNotifier<String?> {
  SettingProxy() : super(null) {
    addListener(() {
      getIt<NetworkService>().setProxy(value);
      getIt<MediaPlayer>().proxyNotifier.value = value;
    });
    bindPreference<String>(
      key: 'proxy',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class NetworkGlobalBusiness extends SingleChildStatelessWidget {
  const NetworkGlobalBusiness({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SettingProxy(),
          lazy: false,
        ),
      ],
      child: child,
    );
  }
}
