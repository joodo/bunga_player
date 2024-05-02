import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class ValueListenableConsumer<T extends ValueListenable<S>, S>
    extends Selector<T, S> {
  ValueListenableConsumer({super.key, required super.builder})
      : super(
          selector: (context, notifier) => notifier.value,
        );
}
