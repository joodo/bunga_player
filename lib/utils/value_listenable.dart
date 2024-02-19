import 'dart:async';

import 'package:async/async.dart';
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

class ValueNotifierWithOldValue<T> extends ChangeNotifier
    implements ValueListenable<T> {
  ValueNotifierWithOldValue(this._value);

  T _value;
  @override
  T get value => _value;
  set value(T newValue) {
    if (newValue == _value) return;
    _oldValue = _value;
    _value = newValue;
    notifyListeners();
  }

  T? _oldValue;
  T? get oldValue => _oldValue;
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

class AutoResetNotifier extends ChangeNotifier
    implements ValueListenable<bool> {
  AutoResetNotifier(this.cooldown);

  final Duration cooldown;

  bool __value = false;
  set _value(bool newValue) {
    if (__value == newValue) return;
    __value = newValue;
    notifyListeners();
  }

  @override
  bool get value => __value;

  void mark({bool keep = false}) {
    _value = true;
    keep ? _resetTimer.cancel() : _resetTimer.reset();
  }

  late final _resetTimer = RestartableTimer(
    cooldown,
    () => _value = false,
  )..cancel();

  @override
  void dispose() {
    _resetTimer.cancel();
    super.dispose();
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
