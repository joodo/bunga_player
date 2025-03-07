import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class ValueListenableProxyProvider<T, R> extends SingleChildStatelessWidget {
  final ValueListenable<R> valueListenable;
  final T Function(R value) proxy;

  const ValueListenableProxyProvider({
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

class ProxyFutureProvider<T, R> extends SingleChildStatelessWidget {
  final Future<T>? Function(R value) proxy;
  final T initialData;
  final Widget Function(BuildContext context, Widget? child)? builder;

  const ProxyFutureProvider({
    super.key,
    super.child,
    required this.proxy,
    required this.initialData,
    this.builder,
  });

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Consumer<R>(
      builder: (context, value, child) => FutureProvider<T>.value(
        value: proxy(value),
        initialData: initialData,
        builder: this.builder,
        child: child,
      ),
      child: child,
    );
  }
}
