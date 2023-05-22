import 'package:flutter/material.dart';

final globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showSnackBar(String text) {
  final theme = Theme.of(globalMessengerKey.currentContext!);
  final backgroundColor =
      theme.snackBarTheme.backgroundColor ?? theme.colorScheme.surface;
  final snackBar = SnackBar(
    content: Text(text),
    backgroundColor: backgroundColor.withOpacity(0.9),
    margin: const EdgeInsets.only(left: 20, right: 20, bottom: 72),
    duration: const Duration(milliseconds: 1500),
    behavior: SnackBarBehavior.floating,
  );
  globalMessengerKey.currentState!.showSnackBar(snackBar);
}
