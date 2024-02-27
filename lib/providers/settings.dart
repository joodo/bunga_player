import 'package:bunga_player/services/network.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingProxy extends ValueNotifier<String?> {
  SettingProxy() : super(getIt<Preferences>().get<String>('proxy')) {
    addListener(() {
      getIt<NetworkService>().setProxy(value);
      getIt<Preferences>().set('proxy', value);
    });
  }
}

final settingProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => SettingProxy(), lazy: false),
  ],
);
