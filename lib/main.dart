import 'package:bunga_player/common/im.dart';
import 'package:bunga_player/common/snack_bar.dart';
import 'package:bunga_player/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  initMeeduPlayer();
  await windowManager.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => IM(),
      child: const BungaApp(),
    ),
  );
}

class BungaApp extends StatelessWidget {
  const BungaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bunga Player',
      scaffoldMessengerKey: globalMessengerKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF5C253),
      ),
      home: const Scaffold(
        body: MainScreen(),
      ),
    );
  }
}
