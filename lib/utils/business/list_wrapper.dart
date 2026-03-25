import 'dart:collection';

class ListWrapper<T> extends ListBase<T> {
  final List<T> _inner;
  ListWrapper([Iterable<T> initial = const []])
    : _inner = List<T>.from(initial);

  @override
  int get length => _inner.length;

  @override
  set length(int newLength) => _inner.length = newLength;

  @override
  T operator [](int index) => _inner[index];

  @override
  void operator []=(int index, T value) => _inner[index] = value;
}
