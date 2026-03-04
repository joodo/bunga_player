import 'dart:async';

import 'package:flutter/foundation.dart';

class SimpleEvent extends ChangeNotifier {
  void fire() => notifyListeners();
}

class SimpleEventStream<T> {
  final _controller = StreamController<T>.broadcast();

  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _controller.stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  void fire(T data) => _controller.add(data);

  void dispose() {
    _controller.close();
  }
}
