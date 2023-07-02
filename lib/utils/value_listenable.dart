import 'package:flutter/foundation.dart';

class ReadonlyStreamNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  T _value;
  ReadonlyStreamNotifier(this._value);

  late final Stream<T> _stream;
  void bind(Stream<T> stream) {
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
  late final ValueSetter<T> _streamSetter;

  StreamNotifier(this._value);
  void bind(Stream<T> stream, ValueSetter<T> streamSetter) {
    _streamSetter = streamSetter;
    stream.listen((value) {
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
