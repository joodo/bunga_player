import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/ui/actions.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/screens/player_section/danmaku_player.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
import 'package:bunga_player/screens/player_section/volume_popup.dart';
import 'package:bunga_player/player/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
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
        getIt<Player>().videoWidget,
        const DanmakuPlayer(),
        const PopmojiPlayer(),
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
