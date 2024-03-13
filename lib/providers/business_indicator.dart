import 'package:flutter/material.dart';

class CatIndicator extends ChangeNotifier {
  String? _title;
  String? get title => _title;
  set title(String? value) {
    if (value == _title) return;
    _title = value;
    notifyListeners();
  }

  bool __busy = false;
  bool get busy => __busy;
  set _busy(bool newValue) {
    if (newValue == __busy) return;
    __busy = newValue;
    notifyListeners();
  }

  Future<T> run<T>(Future<T> Function() job) async {
    final oldTitle = _title;
    _busy = true;
    try {
      return await job();
    } catch (e) {
      _title = oldTitle;
      rethrow;
    } finally {
      _busy = false;
    }
  }
}
