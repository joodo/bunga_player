import 'package:flutter/foundation.dart';

class StreamNotifier<T> extends ValueListenable<T> {
  late final Stream<T> _stream;
  final List<VoidCallback> _listeners = [];
  late T _value;

  StreamNotifier({required T initialValue, required Stream<T> stream}) {
    _value = initialValue;
    _stream = stream;

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

class ValueNotifierWithReset<T> extends ValueNotifier<T> {
  late T _initValue;

  ValueNotifierWithReset(T value) : super(value) {
    _initValue = value;
  }

  void reset() {
    value = _initValue;
  }
}

class ProxyValueNotifier<T1, T2> extends ValueListenable<T1> {
  T1 _defaultProxyFunc(originValue) => originValue as T1;

  ProxyValueNotifier({
    T1 Function(T2 originValue)? proxy,
    required ValueListenable<T2> from,
  }) {
    final proxyFunc = proxy ?? _defaultProxyFunc;
    _value = proxyFunc(from.value);

    from.addListener(() => _setValue(proxyFunc(from.value)));
  }

  late T1 _value;
  @override
  T1 get value => _value;
  void _setValue(newValue) {
    if (newValue == _value) return;

    _value = newValue;
    for (var callback in _listeners) {
      callback.call();
    }
  }

  final List<VoidCallback> _listeners = [];
  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);
  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
}

class PrivateValueNotifier<T> extends ValueNotifier<T> {
  PrivateValueNotifier(super.value);

  late final _readonly = ProxyValueNotifier<T, T>(from: this);
  ValueListenable<T> get readonly => _readonly;
}
