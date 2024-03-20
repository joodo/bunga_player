import 'dart:async';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart' as services;
import 'package:bunga_player/screens/main_screen.dart';
import 'package:bunga_player/screens/wrappers/wrap.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(details);
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await services.init();

      await windowManager.ensureInitialized();
      windowManager.setMinimumSize(const Size(800, 600));

      final app = SingleChildBuilder(
        builder: (context, child) => MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFFF5C253),
          ),
          home: Material(child: child),
        ),
      );
      runApp(wrap(app, const MainScreen()));
    },
    (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
      throw error;
    },
  );
}
