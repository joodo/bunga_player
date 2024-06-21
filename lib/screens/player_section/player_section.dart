import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/screens/player_section/saved_position_hint.dart';
import 'package:bunga_player/ui/actions.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/screens/player_section/danmaku_player.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
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
        const _GestureDetector(),
        const Positioned(
          top: 24,
          left: 24,
          child: _VolumePopup(),
        ),
        const Positioned(
          bottom: 8,
          right: 12,
          child: SavedPositionHint(),
        ),
      ],
    );
  }
}

class _GestureDetector extends StatelessWidget {
  const _GestureDetector();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => Actions.invoke(
          context, SetFullScreenIntent(!context.read<IsFullScreen>().value)),
      onTap: () => Actions.maybeInvoke(context, const TogglePlayIntent()),
    );
  }
}

class _VolumePopup extends StatelessWidget {
  const _VolumePopup();

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              width: 16,
              child: RotatedBox(
                quarterTurns: -1,
                child: Selector<PlayVolume, double>(
                  selector: (context, volume) => volume.value.volume / 100,
                  builder: (context, value, child) =>
                      TweenAnimationBuilder<double>(
                    tween: Tween(end: value),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Icon(
              Icons.volume_up,
              color: Theme.of(context).indicatorColor,
            ),
          ],
        ),
      ),
    );
    return Selector<JustAdjustedVolumeByKey, bool>(
      selector: (context, justAdjusted) {
        final show = context.read<ShouldShowHUD>().value;
        return !show && justAdjusted.value;
      },
      builder: (context, show, child) => AnimatedOpacity(
        opacity: show ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: card,
      ),
    );
  }
}
