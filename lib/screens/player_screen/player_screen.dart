import 'package:bunga_player/screens/widgets/split_view.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel/panel.dart';
import 'player_widget/player_widget.dart';
import 'danmaku_control.dart';
import 'business.dart';

class PlayerScreen extends StatelessWidget {
  static const panelWidth = 300.0;
  static const danmakuHeight = 64.0;

  const PlayerScreen({super.key});

  // Panel
  @override
  Widget build(BuildContext context) {
    final body = Consumer2<Panel?, DanmakuVisible>(
      builder: (context, panel, danmakuVisible, child) {
        final playerWidget = child!.card(margin: EdgeInsets.all(0));
        final danmakuWidget = danmakuVisible.value
            ? const DanmakuControl().constrained(
                key: Key('danmaku'),
                height: danmakuHeight,
              )
            : const SizedBox.shrink(key: Key('none'));
        return [playerWidget.flexible(), _animate(danmakuWidget, .vertical)]
            .toColumn()
            .splitView(
              minSize: 260.0,
              size: 300.0,
              maxSize: 450.0,
              direction: .right,
              split: panel,
            )
            .animate(const Duration(milliseconds: 350), Curves.easeOutCubic);
      },
      child: const PlayerWidget(),
    );

    return body.playScreenBusiness();
  }

  Widget _animate(Widget widget, Axis axis) => widget.animatedSwitcher(
    duration: const Duration(milliseconds: 350),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) => SizeTransition(
      sizeFactor: animation,
      axis: axis,
      axisAlignment: -1.0,
      child: child,
    ),
  );
}
