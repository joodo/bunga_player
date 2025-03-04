import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play/service/service.media_kit.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import '../business.dart';
import 'header.dart';
import 'progress_bar.dart';
import 'saved_position_hint.dart';
import 'video_control.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      [
        const Header().padding(vertical: 4.0),
        Video(
          controller: (getIt<PlayService>() as MediaKitPlayService).controller,
          // use mpv subtitle
          subtitleViewConfiguration:
              const SubtitleViewConfiguration(visible: false),
          wakelock: false,
          controls: NoVideoControls,
        ).flexible(),
        const VideoProgressBar().constrained(height: 16),
        const VideoControl().constrained(height: 64),
      ].toColumn(),
      if (!context.watch<BusyCount>().isBusy)
        const SavedPositionHint().positioned(bottom: 72, right: 12),
    ].toStack();
  }
}
