import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart' as services;
import 'package:bunga_player/screens/main_screen.dart';
import 'package:bunga_player/screens/wrappers/wrap.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/ssl_walkthrough.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:platform/platform.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(details);
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      if (const LocalPlatform().isWindows) sslWalkthrough();

      await services.init();

      await initWindow();

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

Future<void> initWindow() async {
  await windowManager.ensureInitialized();

  const minSize = Size(900, 720);

  late WindowOptions windowOptions;

  try {
    final windowInfo =
        jsonDecode(getIt<Preferences>().get<String>('window_info')!);

    windowOptions = WindowOptions(
      size: Size(windowInfo['width'], windowInfo['height']),
      minimumSize: minSize,
    );
  } catch (e) {
    windowOptions = const WindowOptions(
      size: minSize,
      minimumSize: minSize,
      center: true,
    );
  }

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  AppLifecycleListener(
    onExitRequested: () async {
      final size = await windowManager.getSize();

      await getIt<Preferences>().set(
        'window_info',
        jsonEncode({
          'width': size.width,
          'height': size.height,
        }),
      );
      return AppExitResponse.exit;
    },
  );
}
