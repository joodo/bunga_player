import 'package:animations/animations.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class ThemeWrapper extends SingleChildStatelessWidget {
  static const seedColor = Color(0xFFF5C253);

  const ThemeWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);

    final themeData = ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        for (final platform in TargetPlatform.values)
          platform: const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.horizontal,
          ),
      }),
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      sliderTheme: const SliderThemeData(
        showValueIndicator: ShowValueIndicator.always,
        year2023: false,
      ),
    ).useSystemChineseFont(Brightness.dark);

    return Theme(
      data: themeData,
      child: child!,
    );
  }
}
