import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play/service/service.media_kit.dart';
import 'package:bunga_player/services/services.dart';

import 'danmaku_layer.dart';
import 'interactive_layer.dart';
import 'chrome_layer/chrome_layer.dart';
import 'popmoji_layer.dart';
import 'popup_layer/popup_layer.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IsInChannel>(
      builder: (context, inChannel, child) => [
        child!,
        if (inChannel.value) const DanmakuLayer(),
        if (inChannel.value) const PopmojiLayer(),
        InteractiveLayer(),
        const ChromeLayer(),
        const PopupLayer(),
      ].toStack(fit: StackFit.expand),
      child: _createVideoPlayerLayer(),
    );
  }

  Widget _createVideoPlayerLayer() => Video(
    controller: (getIt<PlayService>() as MediaKitPlayService).controller,
    // use mpv subtitle
    subtitleViewConfiguration: const SubtitleViewConfiguration(visible: false),
    wakelock: false,
    controls: NoVideoControls,
  );
}
