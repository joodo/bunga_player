import 'dart:async';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart' as services;
import 'package:bunga_player/screens/main_screen.dart';
import 'package:bunga_player/screens/wrappers/wrap.dart';
import 'package:bunga_player/utils/slider_dense_track_shape.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
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
          theme: _themeData(),
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

ThemeData _themeData() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFF5C253),
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    menuTheme: const MenuThemeData(
      style: MenuStyle(visualDensity: VisualDensity.standard),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: colorScheme.secondary,
      thumbColor: colorScheme.secondary,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      valueIndicatorColor: colorScheme.secondary,
      trackShape: SliderDenseTrackShape(),
      showValueIndicator: ShowValueIndicator.always,
    ),
  ).useSystemChineseFont(Brightness.dark);
}
