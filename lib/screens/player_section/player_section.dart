import 'dart:async';

import 'package:bunga_player/screens/player_section/play_gesture_detector.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/screens/player_section/danmaku_player.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
import 'package:bunga_player/player/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

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
        const PlayGestureDetector(),
        const Positioned(
          top: 48,
          left: 24,
          child: _VolumePopup(),
        ),
      ],
    );
  }
}

class _VolumePopup extends StatefulWidget {
  const _VolumePopup();

  @override
  State<_VolumePopup> createState() => _VolumePopupState();
}

class _VolumePopupState extends State<_VolumePopup> {
  final _deviceVolumeStreamController = StreamController<double>.broadcast();
  late final StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = FlutterVolumeController.addListener(
      (value) => _deviceVolumeStreamController.add(value),
    );
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _deviceVolumeStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget indicatorBuilder(
      BuildContext context,
      double percent,
      Widget? child,
    ) {
      return TweenAnimationBuilder<double>(
        tween: Tween(end: percent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => LinearProgressIndicator(
          value: value,
        ),
      );
    }

    final card = Card(
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Selector<JustAdjustedByShortHand, ShortHandAction?>(
            selector: (context, notifier) => notifier.action,
            builder: (context, action, child) {
              if (action == null) return const SizedBox.shrink();

              final indicator = switch (action) {
                ShortHandAction.volume => Selector<PlayVolume, double>(
                    selector: (context, volume) => volume.value.volume / 100,
                    builder: indicatorBuilder,
                  ),
                ShortHandAction.deviceVolume => StreamBuilder<double>(
                    stream: _deviceVolumeStreamController.stream,
                    initialData: 0,
                    builder: (context, snapshot) =>
                        indicatorBuilder(context, snapshot.data!, null),
                  ),
                ShortHandAction.deviceBrightness => StreamBuilder<double>(
                    stream: ScreenBrightness().onCurrentBrightnessChanged,
                    initialData: 0,
                    builder: (context, snapshot) =>
                        indicatorBuilder(context, snapshot.data!, null),
                  ),
              };

              return Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    width: 16,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: indicator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Icon(
                    action == ShortHandAction.deviceBrightness
                        ? Icons.sunny
                        : Icons.volume_up,
                    color: Theme.of(context).indicatorColor,
                  ),
                ],
              );
            }),
      ),
    );

    return Selector<JustAdjustedByShortHand, bool>(
      selector: (context, justAdjusted) {
        if (!justAdjusted.value) return false;
        if (justAdjusted.action == ShortHandAction.volume &&
            context.read<ShouldShowHUD>().value) return false;
        return true;
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
