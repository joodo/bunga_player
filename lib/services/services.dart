import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play/service/service.media_kit.dart';
import 'package:bunga_player/ui/toast.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/network/service.dart';

import 'preferences.dart';
import 'exit_callbacks.dart';
import 'permissions.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerSingleton(const Permissions());
  getIt.registerSingleton(await Preferences.create());
  getIt.registerSingleton(await PackageInfo.fromPlatform());
  getIt.registerSingleton(Toast());
  getIt.registerSingleton(ExitCallbacks());
  getIt.registerSingleton<PlayService>(MediaKitPlayService());
  getIt.registerSingleton(NetworkService());
  getIt.registerSingleton(ConsoleService());
}
