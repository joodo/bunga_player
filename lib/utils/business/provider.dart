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
      builder: (context, value, child) =>
          Provider<T>.value(value: proxy(value), child: child),
      child: child,
    );
  }
}

class ProxyFutureProvider<TInput, TOutput> extends SingleChildStatelessWidget {
  final TOutput? Function(TInput? input)? initial;
  final Future<TOutput?> Function(TInput? input) create;
  final void Function(TOutput? previous)? dispose;

  final bool? lazy;

  const ProxyFutureProvider({
    super.key,
    this.initial,
    required this.create,
    this.dispose,
    this.lazy,
    super.child,
  });

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<TInput?, _FutureHolder<TInput, TOutput>>(
          create: (_) => _FutureHolder<TInput, TOutput>(
            initial: initial,
            create: create,
            dispose: dispose,
          ),
          update: (_, input, holder) {
            holder!.setInput(input);
            return holder;
          },
          lazy: lazy,
        ),
        ProxyProvider<_FutureHolder<TInput, TOutput>, TOutput?>(
          update: (_, holder, _) => holder.output,
          lazy: lazy,
        ),
      ],
      child: child,
    );
  }
}

class _FutureHolder<TInput, TOutput> extends ChangeNotifier {
  final TOutput? Function(TInput? input)? _initial;
  final Future<TOutput?> Function(TInput? input) _create;
  final void Function(TOutput? value)? _dispose;

  TOutput? _current;
  TInput? _lastInput;

  TOutput? get output => _current;

  _FutureHolder({
    required TOutput? Function(TInput? input)? initial,
    required Future<TOutput?> Function(TInput? input) create,
    required void Function(TOutput?)? dispose,
  }) : _initial = initial,
       _create = create,
       _dispose = dispose;

  void setInput(TInput? input) {
    if (input == _lastInput) return;
    _lastInput = input;

    // dispose old
    if (_current != null) {
      _dispose?.call(_current);
      _current = null;
      notifyListeners();
    }

    // initial fallback
    if (_initial != null) {
      _current = _initial(input);
      notifyListeners();
    }

    // async build new
    _create(input).then((value) {
      if (_lastInput == input) {
        _current = value;
        notifyListeners();
      } else {
        _dispose?.call(value);
      }
    });
  }

  @override
  void dispose() {
    _dispose?.call(_current);
    super.dispose();
  }
}
