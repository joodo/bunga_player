import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/screens/widgets/split_view.dart';

import 'panel/panel.dart';
import 'player_widget/player_widget.dart';
import 'danmaku_control.dart';
import 'business.dart';

class PlayerScreen extends StatelessWidget {
  static final playerKey = GlobalKey();
  static const panelWidth = 300.0;
  static const danmakuHeight = 64.0;

  const PlayerScreen({super.key});

  // Panel
  @override
  Widget build(BuildContext context) {
    final body = Consumer2<Panel?, DanmakuVisible>(
      builder: (context, panel, danmakuVisible, child) {
        final playerWidget = child!;
        final danmakuWidget = Consumer<IsInChannel>(
          builder: (context, isInChannel, child) => isInChannel.value
              ? RepaintBoundary(
                  child: const DanmakuControl().constrained(
                    key: Key('danmaku'),
                    height: danmakuHeight,
                  ),
                )
              : const SizedBox.shrink(),
        );
        return [
              playerWidget.positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: danmakuVisible.value ? danmakuHeight : 0,
                animate: true,
              ),
              danmakuWidget.positioned(
                left: 0,
                right: 0,
                height: danmakuHeight,
                bottom: danmakuVisible.value ? 0 : -danmakuHeight,
                animate: true,
              ),
            ]
            .toStack()
            .splitView(
              minSize: 260.0,
              size: 300.0,
              maxSize: 450.0,
              direction: .right,
              split: panel,
            )
            .animate(const Duration(milliseconds: 350), Curves.easeOutCubic);
      },
      child: PlayerWidget(key: playerKey),
    );

    return body.playScreenBusiness(
      getChildContext: () => playerKey.currentContext!,
    );
  }
}
