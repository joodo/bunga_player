import 'package:bunga_player/services/network.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'player.dart';
import 'player.media_kit.dart';
import 'preferences.dart';
import 'toast.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerSingleton<Preferences>(await Preferences.create());
  getIt.registerSingleton<PackageInfo>(await PackageInfo.fromPlatform());
  getIt.registerSingleton<Toast>(Toast());
  getIt.registerSingleton<Player>(MediaKitPlayer());
  getIt.registerSingleton<NetworkService>(NetworkService());
}
