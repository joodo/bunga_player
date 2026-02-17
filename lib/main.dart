import 'dart:io';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart' as services;
import 'package:bunga_player/wrappers/wrap.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  Animate.restartOnHotReload = true;

  Provider.debugCheckInvalidValueType = null;

  WidgetsFlutterBinding.ensureInitialized();

  await initializeLogger();

  await services.init();

  if (kIsDesktop) {
    await windowManager.ensureInitialized();
    windowManager.setMinimumSize(const Size(800, 480));
  } else if (Platform.isAndroid) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  runApp(WrappedWidget());
}
