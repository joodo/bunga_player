import 'package:bot_toast/bot_toast.dart';
import 'package:bunga_player/constants/global_keys.dart';
import 'package:bunga_player/services/get_it.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/screens/main_screen.dart';
import 'package:bunga_player/wrapper/wrap.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  windowManager.setMinimumSize(const Size(800, 600));

  await Preferences().init();
  getIt.registerSingleton<PackageInfo>(await PackageInfo.fromPlatform());

  final home = wrap(const MainScreen());
  runApp(
    MaterialApp(
      navigatorKey: rootNavigatorKey,
      scaffoldMessengerKey: globalMessengerKey,
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF5C253),
      ),
      home: home,
    ),
  );
}
