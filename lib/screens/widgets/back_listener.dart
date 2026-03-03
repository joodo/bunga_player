import 'package:bunga_player/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class BackListener extends SingleChildStatefulWidget {
  final Future<bool> Function() callback;
  const BackListener(this.callback, {super.key, super.child});

  @override
  State<BackListener> createState() => _BackListenerState();
}

class _BackListenerState extends SingleChildState<BackListener> {
  late final _backCallbacks = context.read<BackCallbacks>();

  @override
  void initState() {
    super.initState();
    _backCallbacks.add(widget.callback);
  }

  @override
  void didUpdateWidget(BackListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.callback != oldWidget.callback) {
      _backCallbacks.remove(oldWidget.callback);
      _backCallbacks.add(widget.callback);
    }
  }

  @override
  void dispose() {
    _backCallbacks.remove(widget.callback);
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child ?? const SizedBox.shrink();
  }
}

extension OnBackExtension on Widget {
  Widget onBack(Future<bool> Function() callback, {Key? key}) =>
      BackListener(callback, key: key, child: this);
  Widget onBackPop({Key? key}) => Builder(
    builder: (context) =>
        BackListener(Navigator.of(context).maybePop, key: key, child: this),
  );
}
