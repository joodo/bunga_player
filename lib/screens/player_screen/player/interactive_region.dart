import 'dart:math';

import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ui.dart';

class DesktopInteractiveRegion extends StatelessWidget {
  const DesktopInteractiveRegion({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShouldShowHUD>(
      builder: (context, shouldShowHUDNotifier, child) => MouseRegion(
        opaque: false,
        cursor: shouldShowHUDNotifier.value
            ? SystemMouseCursors.basic
            : SystemMouseCursors.none,
        onEnter: (event) => shouldShowHUDNotifier.unlock('interactive'),
        onHover: (event) {
          if (_isInUISection(context, event)) {
            shouldShowHUDNotifier.lockUp('interactive');
          } else {
            shouldShowHUDNotifier.unlock('interactive');
            shouldShowHUDNotifier.mark();
          }
        },
        child: GestureDetector(
          onTap: Actions.handler(
            context,
            ToggleIntent(forgetSavedPosition: true),
          ),
          onDoubleTap: context.read<IsFullScreen>().toggle,
        ),
      ),
    );
  }

  bool _isInUISection(BuildContext context, PointerHoverEvent event) {
    final y = event.localPosition.dy;
    final widgetHeight = (context.findRenderObject()! as RenderBox).size.height;

    // In channel section
    if (y < 72.0) return true;

    // In control or progress section
    if (y > widgetHeight - PlayerUI.videoControlHeight - 12.0 &&
        y < widgetHeight) {
      return true;
    }

    return false;
  }
}

enum _VolumeAdjustType { media, voice }

class TouchInteractiveRegion extends StatefulWidget {
  const TouchInteractiveRegion({super.key});

  @override
  State<TouchInteractiveRegion> createState() => _TouchInteractiveRegionState();
}

class _TouchInteractiveRegionState extends State<TouchInteractiveRegion> {
  late final _showHUDNotifier = context.read<ShouldShowHUD>();

  Offset _dragStartPoint = Offset.zero;

  // Horizontal drag
  Duration _dargStartVideoPosition = Duration.zero;
  bool _isPlayingBeforeDrag = false;

  // Vertical drag
  bool _isAdjustingBrightness = false;
  double _dragStartDeviceValue = 0;
  _VolumeAdjustType _volumeAdjustType = _VolumeAdjustType.media;
  double _farthestX = 0;

  @override
  Widget build(BuildContext context) {
    final play = getIt<PlayService>();
    final voiceNotifier = context.read<AgoraClient>().volumeNotifier;
    return GestureDetector(
      onTap: () => _showHUDNotifier.value
          ? _showHUDNotifier.reset()
          : _showHUDNotifier.mark(),
      onDoubleTap: Actions.handler(
        context,
        ToggleIntent(forgetSavedPosition: true),
      ),
      onHorizontalDragStart: (details) {
        _showHUDNotifier.lockUp('drag');

        _dragStartPoint = details.localPosition;
        _dargStartVideoPosition = play.positionNotifier.value;

        _isPlayingBeforeDrag = play.playStatusNotifier.value.isPlaying;
        play.pause();
      },
      onHorizontalDragUpdate: (details) {
        final xOffset = details.localPosition.dx - _dragStartPoint.dx;
        final positionOffset = Duration(
          seconds: xOffset.toInt() ~/ 20,
        );
        play.seek(_dargStartVideoPosition + positionOffset);
      },
      onHorizontalDragEnd: (details) {
        final xOffset = details.localPosition.dx - _dragStartPoint.dx;
        final positionOffset = Duration(
          seconds: xOffset.toInt() ~/ 20,
        );
        Actions.invoke(
          context,
          SeekIntent(_dargStartVideoPosition + positionOffset),
        );

        if (_isPlayingBeforeDrag) play.play();

        context.read<ShouldShowHUD>().unlock('drag');
      },
      onVerticalDragStart: (details) {
        _dragStartPoint = details.localPosition;

        _isAdjustingBrightness = _dragStartPoint.dx < context.size!.width / 2;

        if (_isAdjustingBrightness) {
          // Adjust brightness
          _dragStartDeviceValue =
              context.read<ScreenBrightnessNotifier>().value;
        } else {
          // Adjust volume
          _farthestX = _dragStartPoint.dx;
          if (_volumeAdjustType == _VolumeAdjustType.voice) {
            if (_canAdjustVoice()) {
              _dragStartDeviceValue = voiceNotifier.value.volume.toDouble();
              return;
            } else {
              // Last time adjust voice, but cannot adjust this time
              _volumeAdjustType = _VolumeAdjustType.media;
            }
          }

          _dragStartDeviceValue = play.volumeNotifier.value.volume.toDouble();
        }
      },
      onVerticalDragUpdate: (details) {
        final delta = _dragStartPoint.dy - details.localPosition.dy;

        if (_isAdjustingBrightness) {
          // Adjust brightness
          final target = (_dragStartDeviceValue + delta / 500).clamp(0, 1.0);
          context.read<ScreenBrightnessNotifier>().value = target.toDouble();
        } else {
          if (_volumeAdjustType == _VolumeAdjustType.voice) {
            // Adjust voice
            voiceNotifier.value = Volume(
              volume: (_dragStartDeviceValue + delta / 5).toInt(),
            );
            if (!_canAdjustVoice() ||
                _farthestX - details.localPosition.dx > 100.0) {
              _volumeAdjustType = _VolumeAdjustType.media;
              _dragStartDeviceValue =
                  play.volumeNotifier.value.volume.toDouble();
              _farthestX = details.localPosition.dx;
            } else {
              _farthestX = max(_farthestX, details.localPosition.dx);
            }
          } else {
            // Adjust media
            play.volumeNotifier.value = Volume(
              volume: (_dragStartDeviceValue + delta / 5).toInt(),
            );
            if (!_canAdjustVoice()) return;
            if (details.localPosition.dx - _farthestX > 100.0) {
              _volumeAdjustType = _VolumeAdjustType.voice;
              _dragStartDeviceValue = voiceNotifier.value.volume.toDouble();
              _dragStartPoint = details.localPosition;
            } else {
              _farthestX = min(_farthestX, details.localPosition.dx);
            }
          }
        }
      },
      onVerticalDragEnd: (details) {
        if (!_isAdjustingBrightness) {
          // Save volumes
          final pref = getIt<Preferences>();
          pref.set('play_volume', play.volumeNotifier.value.volume);
          pref.set('call_volume', voiceNotifier.value.volume);
        }
      },
    );
  }

  bool _canAdjustVoice() {
    final status = context.read<CallStatus?>();
    return status == CallStatus.talking;
  }
}
