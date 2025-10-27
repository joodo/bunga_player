import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:bunga_player/screens/player_screen/player/adjust_indicator.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play/service/service.media_kit.dart';
import 'package:bunga_player/services/services.dart';

import 'danmaku_player.dart';
import 'interactive_region.dart';
import 'saved_position_hint.dart';
import 'ui.dart';
import 'popmoji_player.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IsInChannel>(
      builder: (context, inChannel, child) => [
        _mediaKitPlayer(),
        if (inChannel.value) const DanmakuPlayer(),
        if (inChannel.value) const PopmojiPlayer(),
        kIsDesktop
            ? const DesktopInteractiveRegion()
            : const TouchInteractiveRegion(),
        if (!context.watch<BusyCount>().isBusy)
          const SavedPositionHint().positioned(
            bottom: PlayerUI.videoControlHeight + 8.0,
            right: 12.0,
          ),
        const PlayerUI(),
        const AdjustIndicator().positioned(top: 24.0, left: 24.0),
      ].toStack(fit: StackFit.expand),
    );
  }

  Widget _mediaKitPlayer() => Video(
        controller: (getIt<PlayService>() as MediaKitPlayService).controller,
        // use mpv subtitle
        subtitleViewConfiguration:
            const SubtitleViewConfiguration(visible: false),
        wakelock: false,
        controls: NoVideoControls,
      );
}
