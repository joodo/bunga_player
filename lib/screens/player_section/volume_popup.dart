import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
