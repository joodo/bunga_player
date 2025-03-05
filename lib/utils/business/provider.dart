import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class ValueProxyListenableProvider<T, R> extends SingleChildStatelessWidget {
  final ValueListenable<R> valueListenable;
  final T Function(R value) proxy;

  const ValueProxyListenableProvider({
    super.key,
    super.child,
    required this.valueListenable,
    required this.proxy,
  });

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return ValueListenableBuilder(
      valueListenable: valueListenable,
      builder: (context, value, child) => Provider<T>.value(
        value: proxy(value),
        child: child,
      ),
      child: child,
    );
  }
}
