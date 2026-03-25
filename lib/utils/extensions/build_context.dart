import 'package:flutter/material.dart';

extension SnackBarExtension on BuildContext {
  void clearBars() => ScaffoldMessenger.of(this).clearSnackBars();
  void showSnackBar(SnackBar snackBar) =>
      ScaffoldMessenger.of(this).showSnackBar(snackBar);
  void popBar(String text) => showSnackBar(SnackBar(content: Text(text)));
}
