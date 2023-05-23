import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

final globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showSnackBar(String text) {
  final theme = Theme.of(globalMessengerKey.currentContext!);
  final backgroundColor =
      theme.snackBarTheme.backgroundColor ?? theme.colorScheme.surface;

  BotToast.showText(
    text: text,
    duration: const Duration(milliseconds: 2000),
    borderRadius: const BorderRadius.all(Radius.circular(4)),
    contentColor: backgroundColor.withOpacity(0.9),
    textStyle: theme.textTheme.bodyMedium!,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    wrapToastAnimation: (controller, cancel, Widget child) =>
        CustomAttachedAnimation(
      controller: controller,
      child: child,
    ),
    animationDuration: const Duration(milliseconds: 150),
  );
}

class CustomAttachedAnimation extends StatefulWidget {
  final AnimationController controller;
  final Widget child;

  const CustomAttachedAnimation({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<CustomAttachedAnimation> createState() =>
      _CustomAttachedAnimationState();
}

class _CustomAttachedAnimationState extends State<CustomAttachedAnimation> {
  late final Animation<double> animation;

  @override
  void initState() {
    animation = CurvedAnimation(
      parent: widget.controller,
      curve: Curves.easeInCubic,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
