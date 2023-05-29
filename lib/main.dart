import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:bunga_player/common/im.dart';
import 'package:bunga_player/common/logger.dart';
import 'package:bunga_player/common/snack_bar.dart';
import 'package:bunga_player/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:updat/updat.dart';
import 'package:updat/updat_window_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:http/http.dart' as http;

late final PackageInfo packageInfo;
void main() async {
  initMeeduPlayer();

  await windowManager.ensureInitialized();

  packageInfo = await PackageInfo.fromPlatform();

  runApp(
    ChangeNotifierProvider(
      create: (context) => IMController(),
      child: const BungaApp(),
    ),
  );
}

class BungaApp extends StatelessWidget {
  const BungaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final updatWindowManager = UpdatWindowManager(
      currentVersion: packageInfo.version,
      getLatestVersion: () async {
        final data = await http.get(Uri.parse(
          "https://api.github.com/repos/joodo/bunga_player/releases/latest",
        ));

        final latestVersion = jsonDecode(data.body)["tag_name"];
        logger.i('Latest version: $latestVersion');
        return latestVersion;
      },
      getBinaryUrl: (version) async {
        final data = await http.get(Uri.parse(
          "https://joodo.github.io/bunga_player/update/${Platform.operatingSystem}/binaryUrl.json",
        ));
        final url = jsonDecode(data.body)[version];
        logger.i('Latest version download url: \n$url');
        return url;
      },
      appName: "Bunga Player", // This is used to name the downloaded files.
      getChangelog: (_, __) async {
        // That same latest endpoint gives us access to a markdown-flavored release body. Perfect!
        final data = await http.get(Uri.parse(
          "https://api.github.com/repos/joodo/bunga_player/releases/latest",
        ));
        return jsonDecode(data.body)["body"];
      },
      closeOnInstall: true,
      launchOnExit: false,
      callback: (status) {
        logger.i('Update status: $status');
        if (status == UpdatStatus.available ||
            status == UpdatStatus.availableWithChangelog) {
          Future.delayed(Duration.zero, () => showSnackBar('检查到更新，正在下载…'));
        }
      },
      child: const Scaffold(
        body: MainScreen(),
      ),
    );

    return MaterialApp(
      title: 'Bunga Player',
      scaffoldMessengerKey: globalMessengerKey,
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF5C253),
      ),
      home: updatWindowManager,
    );
  }
}
