import 'package:bunga_player/network/service.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:bunga_player/player/service/service.dart';
import 'package:bunga_player/player/service/service.media_kit.dart';

import 'preferences.dart';
import 'exit_callbacks.dart';
import 'toast.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerSingleton<Preferences>(await Preferences.create());
  getIt.registerSingleton<PackageInfo>(await PackageInfo.fromPlatform());
  getIt.registerSingleton<Toast>(Toast());
  getIt.registerSingleton<ExitCallbacks>(ExitCallbacks());
  getIt.registerSingleton<Player>(MediaKitPlayer());
  getIt.registerSingleton<NetworkService>(NetworkService());
}
