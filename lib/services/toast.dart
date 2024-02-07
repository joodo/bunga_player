import 'package:bunga_player/services/logger.dart';

class Toast {
  void Function(String text)? _showMethod;
  void register(Function(String text) method) => _showMethod = method;
  void unregister(Function(String text) method) {
    if (method == _showMethod) _showMethod = null;
  }

  void show(String text) {
    if (_showMethod == null) {
      logger.w(
          'Toast: show method is not registered yet, can not show message: $text');
      return;
    }
    _showMethod!(text);
  }
}
