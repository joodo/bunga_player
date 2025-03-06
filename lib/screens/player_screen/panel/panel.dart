import 'package:bunga_player/screens/player_screen/actions.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:styled_widget/styled_widget.dart';

class PanelWidget extends SingleChildStatelessWidget {
  final String? title;
  final List<Widget>? actions;
  const PanelWidget({
    super.key,
    super.child,
    this.title,
    this.actions,
  });

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    // FIXME: change to side sheet. See https://m3.material.io/components/side-sheets/guidelines
    return [
      [
        CloseButton(onPressed: Actions.handler(context, ClosePanelIntent())),
        if (title != null)
          Text(
            title!,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ).fontSize(16.0).padding(left: 12.0).expanded(),
        if (actions != null) ...actions!,
      ]
          .toRow(
            crossAxisAlignment: CrossAxisAlignment.center,
          )
          .padding(horizontal: 12.0, top: 12.0, bottom: 0),
      const Divider(),
      child!.expanded(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}

abstract class Panel extends Widget {
  const Panel({super.key});

  String get type;
}
