import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel/panel.dart';
import 'player/player.dart';
import 'danmaku_control/danmaku_control.dart';
import 'business.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  // Panel
  static const _panelWidth = 300.0;
  static const _danmakuHeight = 64.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<Panel?, DanmakuVisible>(
      builder: (context, panel, danmakuVisible, child) => [
        child!.card(margin: EdgeInsets.all(0)).positioned(
              top: 0,
              bottom: danmakuVisible.value ? _danmakuHeight : 0,
              left: 0,
              right: panel != null ? _panelWidth + 8.0 : 0,
              animate: true,
            ),
        const DanmakuControl().positioned(
          left: 0,
          right: panel != null ? _panelWidth + 8.0 : 0,
          height: _danmakuHeight,
          bottom: danmakuVisible.value ? 0 : -_danmakuHeight,
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
              width: _panelWidth,
              top: 0,
              bottom: 0,
              right: panel == null ? -_panelWidth : 0,
              animate: true,
            )
      ]
          .toStack()
          .animate(const Duration(milliseconds: 350), Curves.easeOutCubic),
      child: const Player(),
    ).material().playScreenBusiness();
  }
}
