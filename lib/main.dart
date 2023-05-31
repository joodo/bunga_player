import 'package:bot_toast/bot_toast.dart';
import 'package:bunga_player/common/snack_bar.dart';
import 'package:bunga_player/screens/main_screen.dart';
import 'package:bunga_player/wrapper/log_view.dart';
import 'package:bunga_player/wrapper/update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

late final PackageInfo packageInfo;
void main() async {
  initMeeduPlayer();

  await windowManager.ensureInitialized();

  packageInfo = await PackageInfo.fromPlatform();

  final botToastBuilder = BotToastInit();

  runApp(
    MaterialApp(
      title: 'Bunga Player',
      scaffoldMessengerKey: globalMessengerKey,
      builder: (context, child) {
        child = LogView(child: child!);
        child = UpdateWrapper(packageInfo: packageInfo, child: child);
        child = botToastBuilder(context, child);
        return child;
      },
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF5C253),
      ),
      home: const Scaffold(
        body: MainScreen(),
      ),
    ),
  );
}
