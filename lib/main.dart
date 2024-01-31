import 'dart:async';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart' as services;
import 'package:bunga_player/screens/main_screen.dart';
import 'package:bunga_player/screens/wrappers/wrap.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(details);
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await windowManager.ensureInitialized();
      windowManager.setMinimumSize(const Size(800, 600));

      await services.init();

      final home = wrap(const MainScreen());
      final app = MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFF5C253),
        ),
        home: Scaffold(body: home),
      );
      runApp(app);
    },
    (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
      throw error;
    },
  );
}
