import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/screens/widgets/split_view.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';

import 'footer/footer.dart';
import 'header/header.dart';
import 'panel/panel.dart';
import 'player_widget/player_widget.dart';
import 'business.dart';

class PlayerScreen extends StatelessWidget {
  static final playerKey = GlobalKey();
  static const danmakuHeight = 64.0;

  const PlayerScreen({super.key});

  // Panel
  @override
  Widget build(BuildContext context) {
    final body = Consumer2<Panel?, DanmakuVisible>(
      builder: (context, panel, danmakuVisible, child) =>
          [
                child!.positioned(
                  top: danmakuVisible.value ? Header.height : 0,
                  left: 0,
                  right: 0,
                  bottom: danmakuVisible.value ? Footer.videoControlHeight : 0,
                  animate: true,
                ),
                Header().autoHidden().positioned(top: 0, left: 0, right: 0),
                Footer().autoHidden().positioned(bottom: 0, left: 0, right: 0),
              ]
              .toStack()
              .splitView(
                minSize: 260.0,
                size: 300.0,
                maxSize: 450.0,
                direction: .right,
                split: panel,
              )
              .animate(const Duration(milliseconds: 350), Curves.easeOutCubic),
      child: PlayerWidget(key: playerKey),
    );

    return body.playScreenBusiness(
      getChildContext: () => playerKey.currentContext!,
    );
  }
}

extension _AutoHiddenWrap on Widget {
  Widget autoHidden() => Consumer<ShouldShowHUDNotifier>(
    builder: (context, showNotfier, child) => ValueListenableBuilder(
      valueListenable: showNotfier,
      builder: (context, show, child) =>
          TickerMode(
                enabled: show,
                child: MouseRegion(
                  onEnter: (event) => showNotfier.lockUp('enter footer'),
                  onExit: (event) => showNotfier.unlock('enter footer'),
                  child: this,
                ),
              )
              .opacity(show ? 1.0 : 0.0, animate: true)
              .animate(const Duration(milliseconds: 300), Curves.easeOutCubic)
              .ignorePointer(ignoring: !show),
    ),
  );
}
