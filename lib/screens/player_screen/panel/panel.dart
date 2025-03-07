import 'package:bunga_player/screens/player_screen/actions.dart';
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
    // FIXME: change to side sheet. See https://m3.material.io/components/side-sheets/guidelines
    return [
      [
        CloseButton(onPressed: Actions.handler(context, ClosePanelIntent())),
        if (widget.title != null)
          Text(
            widget.title!,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ).fontSize(16.0).padding(left: 12.0).expanded(),
        if (widget.actions != null) ...widget.actions!,
      ]
          .toRow(
            crossAxisAlignment: CrossAxisAlignment.center,
          )
          .padding(horizontal: 12.0, top: 12.0, bottom: 0),
      const Divider(height: 1.0).padding(top: 4.0),
      ValueListenableBuilder(
        valueListenable: _busyNotifier,
        builder: (context, busy, child) => busy
            ? const LinearProgressIndicator()
            : const SizedBox(
                height: 4.0,
              ),
      ),
      ListenableProvider.value(
        value: _busyNotifier,
        child: child!.expanded(),
      ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
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
