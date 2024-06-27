import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/ui/actions.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

class PlayGestureDetector extends StatefulWidget {
  const PlayGestureDetector({super.key});

  @override
  State<PlayGestureDetector> createState() => _PlayGestureDetectorState();
}

class _PlayGestureDetectorState extends State<PlayGestureDetector> {
  Offset? _dragStartPoint;

  Duration? _dargStartVideoPosition;
  int? _dragUpdatedVideoPostion;

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
        _dragUpdatedVideoPostion = _dargStartVideoPosition!.inMilliseconds;
        Actions.invoke(
          context,
          StartDraggingProgressIntent(_dargStartVideoPosition!),
        );
      },
      onHorizontalDragUpdate: (details) {
        final position = getTargetPosition(details.localPosition);
        if ((position - _dragUpdatedVideoPostion!).abs() < 100) return;

        final target = position.clamp(
          0,
          context.read<PlayDuration>().value.inMilliseconds,
        );
        _dragUpdatedVideoPostion = target;

        Actions.invoke(
          context,
          DraggingProgressIntent(Duration(milliseconds: target)),
        );
      },
      onHorizontalDragEnd: (details) {
        final position = getTargetPosition(details.localPosition);
        final target = position.clamp(
          0,
          context.read<PlayDuration>().value.inMilliseconds,
        );
        Actions.invoke(
          context,
          FinishDraggingProgressIntent(Duration(milliseconds: target)),
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
