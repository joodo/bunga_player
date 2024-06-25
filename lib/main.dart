import 'dart:async';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart' as services;
import 'package:bunga_player/screens/wrappers/wrap.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(details);
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await services.init();

      if (kIsDesktop) {
        await windowManager.ensureInitialized();
        windowManager.setMinimumSize(const Size(800, 600));
      }

      runApp(WrappedWidget());
    },
    (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
      throw error;
    },
  );
}
