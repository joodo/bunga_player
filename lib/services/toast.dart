import 'package:bunga_player/services/logger.dart';
import 'package:flutter/widgets.dart';

typedef ToastShowCallback = Function(String text);

class Toast {
  ToastShowCallback? _showMethod;
  void register(ToastShowCallback method) => _showMethod = method;
  void unregister(ToastShowCallback method) {
    if (method == _showMethod) _showMethod = null;
  }

  void show(
    String text, {
    Widget? action,
    bool withCloseButton = false,
    bool behold = false,
  }) {
    if (_showMethod == null) {
      logger.w(
          'Toast: show method is not registered yet, can not show message: $text');
      return;
    }
    _showMethod!(text);
  }
}
