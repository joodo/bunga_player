import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/screens/widgets/split_view.dart';

import 'panel/panel.dart';
import 'player_widget/player_widget.dart';
import 'danmaku_control.dart';
import 'business.dart';

final _bodyKey = GlobalKey();

class PlayerScreen extends StatelessWidget {
  static const panelWidth = 300.0;
  static const danmakuHeight = 64.0;

  const PlayerScreen({super.key});

  // Panel
  @override
  Widget build(BuildContext context) {
    final body = Consumer2<Panel?, DanmakuVisible>(
      key: _bodyKey,
      builder: (context, panel, danmakuVisible, child) {
        final playerWidget = child!.card(margin: EdgeInsets.all(0));
        final danmakuWidget = const DanmakuControl().constrained(
          key: Key('danmaku'),
          height: danmakuHeight,
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
      child: const PlayerWidget(),
    );

    return body.playScreenBusiness(
      getChildContext: () => _bodyKey.currentContext!,
    );
  }
}
