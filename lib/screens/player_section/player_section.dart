import 'dart:async';

import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/ui/actions.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/screens/player_section/danmaku_player.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
import 'package:bunga_player/player/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

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
          top: 48,
          left: 24,
          child: _VolumePopup(),
        ),
      ],
    );
  }
}

class _GestureDetector extends StatefulWidget {
  const _GestureDetector();

  @override
  State<_GestureDetector> createState() => _GestureDetectorState();
}

class _GestureDetectorState extends State<_GestureDetector> {
  Offset? _dragStartPoint;

  Duration? _dargStartVideoPosition;
  double? _dragStartDeviceValue;
  double? _dragUpdatedDeviceValue;

  @override
  void initState() {
    ScreenBrightness().setAnimate(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsDesktop) {
      return GestureDetector(
        onDoubleTap: Actions.handler(
            context, SetFullScreenIntent(!context.read<IsFullScreen>().value)),
        onTap: () => Actions.maybeInvoke(context, const TogglePlayIntent()),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    int getTargetPosition(Offset localPosition) {
      final videoDuration = context.read<PlayDuration>();
      final dx = localPosition.dx - _dragStartPoint!.dx;
      final position = _dargStartVideoPosition!.inMilliseconds +
          videoDuration.value.inMilliseconds * dx / screenWidth;
      return position.toInt();
    }

    final showHud = context.read<ShouldShowHUD>();
    final gestureDetector = GestureDetector(
      onDoubleTap: () {
        if (context.read<PlayStatus>().isPlaying) {
          context.read<ShouldShowHUD>().mark();
        }
        Actions.maybeInvoke(context, const TogglePlayIntent());
      },
      onTap: () {
        if (showHud.value) {
          showHud.reset();
        } else {
          showHud.mark();
        }
      },
      onHorizontalDragStart: (details) {
        context.read<ShouldShowHUD>().lockUp('drag');
        _dragStartPoint = details.localPosition;

        _dargStartVideoPosition = context.read<PlayPosition>().value;
        Actions.invoke(
          context,
          StartDraggingProgressIntent(_dargStartVideoPosition!),
        );
      },
      onHorizontalDragUpdate: (details) {
        final position = getTargetPosition(details.localPosition);
        Actions.invoke(
          context,
          DraggingProgressIntent(Duration(milliseconds: position.toInt())),
        );
      },
      onHorizontalDragEnd: (details) {
        final position = getTargetPosition(details.localPosition);
        Actions.invoke(
          context,
          FinishDraggingProgressIntent(
            Duration(milliseconds: position.toInt()),
          ),
        );

        _dargStartVideoPosition = null;
        _dragStartPoint = null;
        context.read<ShouldShowHUD>().unlock('drag');
      },
      onVerticalDragStart: (details) async {
        _dragStartPoint = details.localPosition;

        if (_dragStartPoint!.dx < screenWidth / 2) {
          // Adjust brightness
          _dragStartDeviceValue = await ScreenBrightness().current;
        } else {
          // Adjust volume
          _dragStartDeviceValue = await VolumeController().getVolume();
        }
      },
      onVerticalDragUpdate: (details) {
        if (_dragStartDeviceValue == null) return;

        final delta = (_dragStartPoint!.dy - details.localPosition.dy) / 200;
        final target = _dragStartDeviceValue! + delta;

        if (_dragUpdatedDeviceValue != null &&
            (target - _dragUpdatedDeviceValue!).abs() < 0.05) return;
        _dragUpdatedDeviceValue = target.clamp(0.0, 1.0);

        if (_dragStartPoint!.dx < screenWidth / 2) {
          // Adjust brightness
          context
              .read<JustAdjustedByShortHand>()
              .markWithAction(ShortHandAction.deviceBrightness);
          ScreenBrightness().setScreenBrightness(_dragUpdatedDeviceValue!);
        } else {
          // Adjust volume
          context
              .read<JustAdjustedByShortHand>()
              .markWithAction(ShortHandAction.deviceVolume);
          VolumeController().setVolume(
            _dragUpdatedDeviceValue!,
            showSystemUI: false,
          );
        }
      },
      onVerticalDragEnd: (details) {
        _dragStartPoint = null;
        _dragStartDeviceValue = null;
      },
    );

    return Selector<PlayVideoEntry, bool>(
      selector: (context, videoEntryNotifer) => videoEntryNotifer.value == null,
      builder: (context, ignoring, child) => IgnorePointer(
        ignoring: ignoring,
        child: child,
      ),
      child: gestureDetector,
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
    _subscription = VolumeController().listener(
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
