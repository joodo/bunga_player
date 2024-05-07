import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

mixin StreamBinding<T> on ValueNotifier<T> {
  StreamSubscription<T>? _subscription;

  void bind(Stream<T> stream) {
    assert(!isBinded);
    _subscription = stream.listen((value) {
      this.value = value;
    });
  }

  Future<void> unbind() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  bool get isBinded => _subscription != null;
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
  @override
  bool get value => __value;
  set _value(bool newValue) {
    if (__value == newValue) return;
    __value = newValue;
    notifyListeners();
  }

  final _locks = <String>{};
  bool get locked => _locks.isNotEmpty;
  void lock(String locker) {
    _locks.add(locker);
    _resetTimer.cancel();
  }

  void unlock(String locker) {
    _locks.remove(locker);
    if (_locks.isEmpty) _resetTimer.reset();
  }

  void mark() {
    _value = true;
    if (_locks.isEmpty) _resetTimer.reset();
  }

  void reset() {
    assert(_locks.isEmpty);
    _value = false;
    _resetTimer.cancel();
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

extension ToggleBoolNotifier on ValueNotifier<bool> {
  void toggle() {
    value = !value;
  }
}
