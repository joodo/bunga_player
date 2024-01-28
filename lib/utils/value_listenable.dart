import 'dart:async';

import 'package:flutter/foundation.dart';

class ReadonlyStreamValueNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  T _value;
  ReadonlyStreamValueNotifier(this._value);

  StreamSubscription<T> bind(Stream<T> stream) {
    return stream.listen((value) {
      if (_value == value) return;
      _value = value;
      notifyListeners();
    });
  }

  @override
  T get value => _value;
}

class StreamNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  StreamNotifier(this._value);

  bool _isBinded = false;
  bool follow = true;
  late final ValueSetter<T> _streamSetter;
  void bind(Stream<T> stream, ValueSetter<T> streamSetter) {
    if (_isBinded) throw Exception('Notifier already binded');
    _isBinded = true;

    _streamSetter = streamSetter;
    stream.listen((value) {
      if (!follow || _value == value) {
        return;
      }
      _value = value;
      notifyListeners();
    });
  }

  T _value;
  @override
  T get value => _value;
  set value(T newValue) {
    if (_value == newValue) {
      return;
    }
    _value = newValue;
    _streamSetter(newValue);
    notifyListeners();
  }
}

class ValueNotifierWithReset<T> extends ValueNotifier<T> {
  final T _initValue;

  ValueNotifierWithReset(super.value) : _initValue = value;

  void reset() {
    value = _initValue;
  }
}

class ProxyValueNotifier<T1, T2> extends ChangeNotifier
    implements ValueListenable<T1> {
  ProxyValueNotifier({
    required ValueListenable<T2> from,
    T1 Function(T2 originValue)? proxy,
  }) {
    final proxyFunc = proxy ?? (originValue) => originValue as T1;
    _value = proxyFunc(from.value);

    from.addListener(() {
      final newValue = proxyFunc(from.value);
      if (newValue == _value) return;

      _value = newValue;
      notifyListeners();
    });
  }

  late T1 _value;
  @override
  T1 get value => _value;
}

extension Mapping<T> on ValueListenable<T> {
  ProxyValueNotifier<U, T> map<U>(U Function(T originValue) proxy) =>
      ProxyValueNotifier(from: this, proxy: proxy);
  ProxyValueNotifier<T, T> createReadonly() => ProxyValueNotifier(from: this);
}
