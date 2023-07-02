import 'package:flutter/foundation.dart';

class ReadonlyStreamNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  late final Stream<T> _stream;
  late T _value;

  ReadonlyStreamNotifier({required T initialValue, required Stream<T> stream}) {
    _value = initialValue;
    _stream = stream;

    _stream.listen((value) {
      if (_value == value) return;
      _value = value;
      notifyListeners();
    });
  }

  @override
  T get value => _value;
}

class StreamNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  final Stream<T> _stream;
  final ValueSetter<T> _streamSetter;

  StreamNotifier({
    required T initialValue,
    required Stream<T> stream,
    required ValueSetter<T> streamSetter,
  })  : _value = initialValue,
        _stream = stream,
        _streamSetter = streamSetter {
    _stream.listen((value) {
      if (!follow || _value == value) {
        return;
      }
      _value = value;
      notifyListeners();
    });
  }

  bool follow = true;

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

  ValueNotifierWithReset(T value)
      : _initValue = value,
        super(value);

  void reset() {
    value = _initValue;
  }
}

class ProxyValueNotifier<T1, T2> extends ChangeNotifier
    implements ValueListenable<T1> {
  T1 _defaultProxyFunc(originValue) => originValue as T1;

  ProxyValueNotifier({
    required ValueListenable<T2> from,
    T1 Function(T2 originValue)? proxy,
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
    notifyListeners();
  }
}

class PrivateValueNotifier<T> extends ValueNotifier<T> {
  PrivateValueNotifier(super.value);

  late final readonly = ProxyValueNotifier<T, T>(from: this);
}
