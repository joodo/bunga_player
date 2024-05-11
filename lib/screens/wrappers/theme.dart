import 'package:bunga_player/screens/widgets/slider_dense_track_shape.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class ThemeWrapper extends SingleChildStatelessWidget {
  static const seedColor = Color(0xFFF5C253);

  const ThemeWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    final themeData = ThemeData(
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

    return Theme(
      data: themeData,
      child: child!,
    );
  }
}
