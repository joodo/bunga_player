import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
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
    return GestureDetector(
      onDoubleTap: () => Actions.invoke(
          context, SetFullScreenIntent(!context.read<IsFullScreen>().value)),
      onTap: () => Actions.maybeInvoke(context, const TogglePlayIntent()),
      child: Stack(
        fit: StackFit.expand,
        children: [
          media_kit.Video(
            controller: (getIt<Player>() as MediaKitPlayer).controller,
            subtitleViewConfiguration:
                const media_kit.SubtitleViewConfiguration(
              textScaleFactor: 1.0,
            ),
            wakelock: true,
          ),
          AnimatedOpacity(
            opacity: context.select<BusinessIndicator, double>(
                (bi) => bi.currentMissionName == null ? 0.0 : 1.0),
            duration: const Duration(milliseconds: 250),
            child: const PlayerPlaceholder(),
          ),
          Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
              builder: (context) => const PopmojiPlayer(),
            ),
          ),
        ],
      ),
    );
  }
}
