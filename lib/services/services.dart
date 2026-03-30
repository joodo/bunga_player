import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/console/service.dart';
import '/network/service.dart';
import '/preferences/preferences.dart';

import 'permissions.dart';
import 'presence_callbacks.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerSingleton(const Permissions());
  getIt.registerSingleton(await Preferences.create());
  getIt.registerSingleton(await PackageInfo.fromPlatform());
  getIt.registerSingleton(PresenceCallbacks());
  getIt.registerSingleton(NetworkService());
  getIt.registerSingleton(ConsoleService());
}
