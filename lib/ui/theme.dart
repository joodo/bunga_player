import 'package:animations/animations.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';

const seedColor = Color(0xFFF5C253);

final lightTheme = _getThemeData(Brightness.light);
final darkTheme = _getThemeData(Brightness.dark);

ThemeData _getThemeData(Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.horizontal,
          ),
      },
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ),
    sliderTheme: const SliderThemeData(
      showValueIndicator: ShowValueIndicator.onDrag,
      year2023: false,
    ),
    snackBarTheme: SnackBarThemeData(
      insetPadding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 72.0),
      behavior: .floating,
    ),
  ).useSystemChineseFont(brightness);
}
