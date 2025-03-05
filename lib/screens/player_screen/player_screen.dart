import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel/panel.dart';
import 'player/player.dart';
import 'danmaku_control.dart';
import 'business.dart';

class PlayerScreen extends StatelessWidget {
  static const panelWidth = 300.0;
  static const danmakuHeight = 64.0;

  const PlayerScreen({super.key});

  // Panel
  @override
  Widget build(BuildContext context) {
    return Consumer2<Panel?, DanmakuVisible>(
      builder: (context, panel, danmakuVisible, child) => [
        child!.card(margin: EdgeInsets.all(0)).positioned(
              top: 0,
              bottom: danmakuVisible.value ? danmakuHeight : 0,
              left: 0,
              right: panel != null ? panelWidth + 8.0 : 0,
              animate: true,
            ),
        const DanmakuControl().positioned(
          left: 0,
          right: panel != null ? panelWidth + 8.0 : 0,
          height: danmakuHeight,
          bottom: danmakuVisible.value ? 0 : -danmakuHeight,
          animate: true,
        ),
        (panel?.card(
                  key: ValueKey(panel.type),
                  margin: const EdgeInsets.all(0),
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ) ??
                const SizedBox.shrink(key: ValueKey('none')))
            .fadeThroughTransitionSwitcher(
                duration: const Duration(milliseconds: 300))
            .positioned(
              width: panelWidth,
              top: 0,
              bottom: 0,
              right: panel == null ? -panelWidth : 0,
              animate: true,
            )
      ]
          .toStack()
          .animate(const Duration(milliseconds: 350), Curves.easeOutCubic),
      child: const Player(),
    ).material().playScreenBusiness();
  }
}
