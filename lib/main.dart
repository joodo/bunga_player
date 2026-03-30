import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '/services/logger.dart';
import '/services/services.dart' as services;
import '/utils/platform.dart';
import '/wrappers/wrap.dart';

void main() async {
  Animate.restartOnHotReload = true;

  Provider.debugCheckInvalidValueType = null;

  WidgetsFlutterBinding.ensureInitialized();

  await initializeLogger();

  await services.init();

  if (kIsDesktop) {
    await windowManager.ensureInitialized();
    windowManager.setMinimumSize(const Size(480, 480));
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
