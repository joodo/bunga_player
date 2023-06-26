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

class ProxyValueNotifier<T1, T2> extends ValueListenable<T1> {
  ProxyValueNotifier({
    required T1 initialValue,
    required this.proxy,
    ValueListenable<T2>? from,
  }) : _value = initialValue {
    this.from = from;
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

  ValueListenable<T2>? _from;
  ValueListenable<T2>? get from => _from;
  final T1 Function(T2 originValue) proxy;
  void Function()? _proxyFunc;
  set from(ValueListenable<T2>? newNotifier) {
    if (_proxyFunc != null) _from?.removeListener(_proxyFunc!);

    _from = newNotifier;
    if (_from == null) return;

    _proxyFunc = () {
      _setValue(proxy(_from!.value));
    };
    _from!.addListener(_proxyFunc!);
    _setValue(proxy(_from!.value));
  }

  final List<VoidCallback> _listeners = [];
  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);
  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
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
