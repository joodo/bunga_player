import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension BungaStyledWidget on Widget {
  Widget breath() => animate(
        onPlay: (controller) => controller.repeat(),
      )
          .fade(duration: 1000.ms, begin: 0.5, end: 1.0)
          .then(delay: 300.ms)
          .fade(duration: 1000.ms, end: 0.5);
  Widget colorScheme({
    ColorScheme? scheme,
    Color? seedColor,
    Brightness? brightness,
  }) =>
      Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Theme(
            data: ThemeData(
              colorScheme: seedColor != null
                  ? ColorScheme.fromSeed(
                      seedColor: seedColor,
                      brightness: brightness ?? theme.brightness,
                    )
                  : scheme,
              brightness: brightness ?? theme.brightness,
            ),
            child: this,
          );
        },
      );

  Widget animatedSwitcher({
    Key? key,
    required Duration duration,
    Duration? reverseDuration,
    Curve switchInCurve = Curves.linear,
    Curve switchOutCurve = Curves.linear,
    AnimatedSwitcherTransitionBuilder transitionBuilder =
        AnimatedSwitcher.defaultTransitionBuilder,
    AnimatedSwitcherLayoutBuilder layoutBuilder =
        AnimatedSwitcher.defaultLayoutBuilder,
  }) =>
      AnimatedSwitcher(
        key: key,
        duration: duration,
        reverseDuration: reverseDuration,
        switchInCurve: switchInCurve,
        switchOutCurve: switchOutCurve,
        transitionBuilder: transitionBuilder,
        layoutBuilder: layoutBuilder,
        child: this,
      );

  Widget animatedSize({
    Key? key,
    AlignmentGeometry alignment = Alignment.center,
    Curve curve = Curves.linear,
    required Duration duration,
    Duration? reverseDuration,
    Clip clipBehavior = Clip.hardEdge,
    VoidCallback? onEnd,
  }) =>
      AnimatedSize(
        key: key,
        alignment: alignment,
        curve: curve,
        duration: duration,
        reverseDuration: reverseDuration,
        clipBehavior: clipBehavior,
        onEnd: onEnd,
        child: this,
      );

  Actions actions({
    Key? key,
    ActionDispatcher? dispatcher,
    required Map<Type, Action<Intent>> actions,
  }) =>
      Actions(
        dispatcher: dispatcher,
        actions: actions,
        child: this,
      );

  Material material({
    Key? key,
    MaterialType type = MaterialType.canvas,
    double elevation = 0.0,
    Color? color,
    Color? shadowColor,
    Color? surfaceTintColor,
    TextStyle? textStyle,
    BorderRadiusGeometry? borderRadius,
    ShapeBorder? shape,
    bool borderOnForeground = true,
    Clip clipBehavior = Clip.none,
    Duration animationDuration = kThemeChangeDuration,
  }) =>
      Material(
        key: key,
        type: type,
        elevation: elevation,
        color: color,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        textStyle: textStyle,
        borderRadius: borderRadius,
        shape: shape,
        borderOnForeground: borderOnForeground,
        clipBehavior: clipBehavior,
        animationDuration: animationDuration,
        child: this,
      );

  Widget fadeThroughTransitionSwitcher({required Duration duration}) =>
      PageTransitionSwitcher(
        duration: duration,
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: this,
      );
}

extension ControlSliderTheme on Widget {
  Widget controlSliderTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: colorScheme.secondary,
        thumbColor: colorScheme.secondary,
        valueIndicatorColor: colorScheme.tertiary,
        thumbSize: const WidgetStatePropertyAll(Size(4.0, 32.0)),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
        padding: const EdgeInsets.all(0),
        showValueIndicator: ShowValueIndicator.always,
        year2023: false,
      ),
      child: this,
    );
  }
}
