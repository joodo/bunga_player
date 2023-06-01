import 'package:flutter/foundation.dart';

double dToS(Duration duration) {
  return duration.inMilliseconds / 1000.0;
}

Duration sToD(double seconds) {
  return Duration(milliseconds: (seconds * 1000).toInt());
}

String dToHHmmss(Duration d) {
  return d.toString().split('.').first.padLeft(8, "0");
}

class StreamNotifier<T> extends ValueListenable<T> {
  final Stream<T> _stream;
  final List<VoidCallback> _listeners = [];
  T _value;

  StreamNotifier(this._value, this._stream) {
    _stream.listen((value) {
      _value = value;
      for (var callback in _listeners) {
        callback.call();
      }
    });
  }

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  T get value => _value;
}
