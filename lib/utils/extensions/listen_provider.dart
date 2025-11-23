import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension ListenProviderExtension on Widget {
  Widget listenProvider<T>(ValueChanged<T> onChanged) {
    return Selector<T, T>(
      selector: (context, value) => value,
      builder: (context, value, child) {
        onChanged(value);
        return child!;
      },
      child: this,
    );
  }
}
