import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../actions.dart';

class PanelBusyNotifier extends ValueNotifier<bool> {
  PanelBusyNotifier() : super(false);
}

class PanelWidget extends SingleChildStatefulWidget {
  final Widget? title;
  final List<Widget>? actions;
  const PanelWidget({super.key, super.child, this.title, this.actions});

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends SingleChildState<PanelWidget> {
  final _busyNotifier = PanelBusyNotifier();

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final appBar = AppBar(
      leading: CloseButton(
        onPressed: Actions.handler(context, ClosePanelIntent()),
      ),
      title: widget.title,
      actions: widget.actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(2.0),
        child: ValueListenableBuilder(
          valueListenable: _busyNotifier,
          builder: (context, busy, child) =>
              busy ? const LinearProgressIndicator() : const SizedBox.shrink(),
        ),
      ),
    );

    final panel = Scaffold(appBar: appBar, body: child);

    return ListenableProvider.value(value: _busyNotifier, child: panel);
  }

  @override
  void dispose() {
    _busyNotifier.dispose();
    super.dispose();
  }
}

abstract class Panel extends Widget {
  const Panel({super.key});

  String get type;
}
