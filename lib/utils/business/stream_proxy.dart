import 'package:async/async.dart';

class StreamProxy<T> extends StreamGroup<T> {
  StreamProxy() : super();
  StreamProxy.broadcast() : super.broadcast();

  Stream<T>? _source;
  Stream<T>? get source => _source;
  set source(Stream<T>? stream) {
    if (stream == _source) return;

    if (_source != null) remove(_source!);
    _source = stream;

    if (stream != null) add(stream);
  }
}
