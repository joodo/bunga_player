import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/actions/ui.dart';
import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/player_section/danmaku_player.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
import 'package:bunga_player/screens/player_section/volume_popup.dart';
import 'package:bunga_player/services/player.dart';
import 'package:bunga_player/services/player.media_kit.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit;
import 'package:provider/provider.dart';

class PlayerSection extends StatefulWidget {
  const PlayerSection({super.key});

  @override
  State<PlayerSection> createState() => _PlayerSectionState();
}

class _PlayerSectionState extends State<PlayerSection> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        media_kit.Video(
          controller: (getIt<Player>() as MediaKitPlayer).controller,
          // use mpv subtitle
          subtitleViewConfiguration:
              const media_kit.SubtitleViewConfiguration(visible: false),
          wakelock: true,
          controls: media_kit.NoVideoControls,
        ),
        const DanmakuPlayer(),
        Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            builder: (context) => const PopmojiPlayer(),
          ),
          requestFocus: false,
        ),
        AnimatedOpacity(
          opacity: context.select<CatIndicator, double>(
              (bi) => bi.title == null ? 0.0 : 1.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: const PlayerPlaceholder(),
        ),
        const Positioned(
          top: 24,
          left: 24,
          child: VolumePopup(),
        ),
        GestureDetector(
          onDoubleTap: () => Actions.invoke(context,
              SetFullScreenIntent(!context.read<IsFullScreen>().value)),
          onTap: () => Actions.maybeInvoke(context, const TogglePlayIntent()),
        ),
      ],
    );
  }
}
