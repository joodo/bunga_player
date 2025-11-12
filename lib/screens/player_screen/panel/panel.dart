import 'package:bunga_player/screens/player_screen/actions.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class PanelBusyNotifier extends ValueNotifier<bool> {
  PanelBusyNotifier() : super(false);
}

class PanelWidget extends SingleChildStatefulWidget {
  final String? title;
  final List<Widget>? actions;
  const PanelWidget({
    super.key,
    super.child,
    this.title,
    this.actions,
  });

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends SingleChildState<PanelWidget> {
  final _busyNotifier = PanelBusyNotifier();

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final title = [
      CloseButton(onPressed: Actions.handler(context, ClosePanelIntent())),
      if (widget.title != null)
        Text(
          widget.title!,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ).fontSize(16.0).padding(left: 12.0).expanded(),
      if (widget.actions != null) ...widget.actions!,
    ].toRow(crossAxisAlignment: CrossAxisAlignment.center);

    final body = ValueListenableBuilder(
      valueListenable: _busyNotifier,
      builder: (context, busy, child) =>
          busy ? const LinearProgressIndicator() : const SizedBox(height: 4.0),
    );

    final panel = [
      title.padding(horizontal: 12.0, top: 12.0, bottom: 0),
      const Divider(height: 1.0).padding(top: 12.0),
      body,
      child!.material(color: Colors.transparent).expanded(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);

    return ListenableProvider.value(
      value: _busyNotifier,
      child: panel,
    );
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
