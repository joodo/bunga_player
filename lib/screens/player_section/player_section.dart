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
    return Stack(
      fit: StackFit.expand,
      children: [
        media_kit.Video(
          controller: (getIt<Player>() as MediaKitPlayer).controller,
          subtitleViewConfiguration: const media_kit.SubtitleViewConfiguration(
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

class VolumePopup extends StatelessWidget {
  const VolumePopup({
    super.key,
  });

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
                  selector: (context, volume) => volume.volume / 100,
                  builder: (context, value, child) => LinearProgressIndicator(
                    value: value,
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
    return Selector3<IsFullScreen, IsControlSectionHidden,
        JustAdjustedVolumeByKey, bool>(
      selector: (context, p1, p2, p3) => p1.value && p2.value && p3.value,
      builder: (context, show, child) => AnimatedOpacity(
        opacity: show ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: card,
      ),
    );
  }
}
