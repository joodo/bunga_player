import 'package:bunga_player/services/logger.dart';
import 'package:flutter/material.dart';

class Toast {
  ScaffoldMessengerState? _scaffoldMessenger;
  void register(ScaffoldMessengerState messenger) =>
      _scaffoldMessenger = messenger;

  void show(String text) {
    if (_scaffoldMessenger == null) {
      logger.w(
        'Toast: show method is not registered yet, can not show message: $text',
      );
      return;
    }
    _scaffoldMessenger!.showSnackBar(SnackBar(content: Text(text)));
  }
}
