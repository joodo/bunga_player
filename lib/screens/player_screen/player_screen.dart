import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play/service/service.media_kit.dart';
import 'package:bunga_player/screens/player_screen/player/video_control.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel/panel.dart';
import 'player/player.dart';
import 'player/progress_bar.dart';
import 'business.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  // Panel
  static const _panelWidth = 300.0;

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
    return Consumer<Panel?>(
      builder: (context, panel, child) => [
        child!.positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: panel != null ? _panelWidth : 0,
          animate: true,
        ),
        (panel?.card(
                  key: ValueKey(panel.type),
                  elevation: 24.0,
                  margin: const EdgeInsets.all(0),
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
