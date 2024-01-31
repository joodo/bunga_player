import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/providers/ui/ui.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
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
      onDoubleTap: () => Actions.maybeInvoke(
          context, SetFullScreenIntent(!context.read<IsFullScreen>().value)),
      onTap: () => Actions.maybeInvoke(context, const TogglePlayIntent()),
      child: Stack(
        fit: StackFit.expand,
        children: [
          media_kit.Video(
            controller: context.read<VideoPlayer>().controller,
            wakelock: true,
          ),
          AnimatedOpacity(
            opacity: context.watch<BusinessName>().value == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: const PlayerPlaceholder(),
          ),
          const PopmojiPlayer(),
        ],
      ),
    );
  }
}
