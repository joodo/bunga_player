import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

extension ListenProviderExtension on Widget {
  Widget listenProvider<T>(Function(BuildContext context, T value) onChanged) {
    return _ProviderListener<T>(onChange: onChanged, child: this);
  }
}

class _ProviderListener<T> extends SingleChildStatefulWidget {
  final void Function(BuildContext context, T value) onChange;

  const _ProviderListener({super.key, required this.onChange, super.child});

  @override
  State<_ProviderListener<T>> createState() => _ProviderListenerState<T>();
}

class _ProviderListenerState<T> extends SingleChildState<_ProviderListener<T>> {
  T? _lastInstance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentInstance = Provider.of<T>(context);
    if (_lastInstance != currentInstance) {
      _lastInstance = currentInstance;

      runAfterBuild(() {
        if (mounted) {
          widget.onChange(context, currentInstance);
        }
      });
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) =>
      child ?? const SizedBox.shrink();
}
