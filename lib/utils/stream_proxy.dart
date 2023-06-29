import 'package:async/async.dart';

class StreamProxy<T> extends StreamGroup<T> {
  StreamProxy() : super();
  StreamProxy.broadcast() : super.broadcast();

  Stream<T>? _source;
  Stream<T>? get source => _source;

  void setSourceStream(Stream<T> stream) {
    if (_source != null) remove(_source!);
    add(stream);
    _source = stream;
  }

  void setEmpty() {
    if (_source == null) return;
    remove(_source!);
    _source = null;
  }
}
