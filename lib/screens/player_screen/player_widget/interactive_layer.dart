import 'dart:math';

import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'chrome_layer/menu_builder.dart';
import 'chrome_layer/chrome_layer.dart';

class InteractiveLayer extends StatelessWidget {
  const InteractiveLayer({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsDesktop) {
      return const DesktopInteractiveLayer();
    } else {
      return const TouchInteractiveLayer();
    }
  }
}

class DesktopInteractiveLayer extends StatelessWidget {
  const DesktopInteractiveLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final menuController = MenuController();
    return Consumer<ShouldShowHUDNotifier>(
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
        child: MenuBuilder(
          builder: (context, menuChildren, child) => MenuAnchor(
            controller: menuController,
            consumeOutsideTap: true,
            menuChildren: menuChildren,
            child: child!.center(),
          ),
          child: GestureDetector(
            onTap: Actions.handler(
              context,
              ToggleIntent(forgetSavedPosition: true),
            ),
            onDoubleTap: context.read<IsFullScreenNotifier>().toggle,
            onSecondaryTapDown: (details) {
              menuController.open(position: details.localPosition);
            },
          ),
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
    if (y > widgetHeight - ChromeLayer.videoControlHeight - 12.0 &&
        y < widgetHeight) {
      return true;
    }

    return false;
  }
}

enum _VolumeAdjustType { media, voice }

class TouchInteractiveLayer extends StatefulWidget {
  const TouchInteractiveLayer({super.key});

  @override
  State<TouchInteractiveLayer> createState() => _TouchInteractiveLayerState();
}

class _TouchInteractiveLayerState extends State<TouchInteractiveLayer> {
  late final _showHUDNotifier = context.read<ShouldShowHUDNotifier>();

  Offset _dragStartPoint = Offset.zero;

  // Horizontal drag
  Duration _dargStartVideoPosition = Duration.zero;
  bool _isPlayingBeforeDrag = false;

  // Vertical drag
  bool _isAdjustingBrightness = false;
  double _dragStartDeviceValue = 0;
  _VolumeAdjustType _volumeAdjustType = _VolumeAdjustType.media;
  double _farthestX = 0;

  // Lock button
  final _lockButtonVisibleNotifier = AutoResetNotifier(
    const Duration(seconds: 5),
  )..mark();

  @override
  void initState() {
    super.initState();
    _showHUDNotifier.addListener(_onHUDVisibleChanged);
  }

  @override
  Widget build(BuildContext context) {
    final play = getIt<PlayService>();
    final voiceNotifier = context.read<AgoraClient>().volumeNotifier;
    final lockedNotifier = context.watch<ScreenLockedNotifier>();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (lockedNotifier.value) {
          _lockButtonVisibleNotifier.mark();
        } else {
          _showHUDNotifier.value
              ? _showHUDNotifier.reset()
              : _showHUDNotifier.mark();
        }
      },
      onDoubleTap: lockedNotifier.value
          ? null
          : Actions.handler(context, ToggleIntent(forgetSavedPosition: true)),
      onHorizontalDragStart: lockedNotifier.value
          ? null
          : (details) {
              _showHUDNotifier.lockUp('drag');

              _dragStartPoint = details.localPosition;
              _dargStartVideoPosition = play.positionNotifier.value;

              _isPlayingBeforeDrag = play.playStatusNotifier.value.isPlaying;
              play.pause();
            },
      onHorizontalDragUpdate: lockedNotifier.value
          ? null
          : (details) {
              final xOffset = details.localPosition.dx - _dragStartPoint.dx;
              final positionOffset = Duration(seconds: xOffset.toInt() ~/ 5);
              play.seek(_dargStartVideoPosition + positionOffset);
            },
      onHorizontalDragEnd: lockedNotifier.value
          ? null
          : (details) {
              final xOffset = details.localPosition.dx - _dragStartPoint.dx;
              final positionOffset = Duration(seconds: xOffset.toInt() ~/ 5);

              if (_isPlayingBeforeDrag) play.play();
              Actions.invoke(
                context,
                SeekIntent(_dargStartVideoPosition + positionOffset),
              );

              context.read<ShouldShowHUDNotifier>().unlock('drag');
            },
      onVerticalDragStart: lockedNotifier.value
          ? null
          : (details) {
              _dragStartPoint = details.localPosition;

              _isAdjustingBrightness =
                  _dragStartPoint.dx < context.size!.width / 2;

              if (_isAdjustingBrightness) {
                // Adjust brightness
                _dragStartDeviceValue = context
                    .read<ScreenBrightnessNotifier>()
                    .value;
              } else {
                // Adjust volume
                _farthestX = _dragStartPoint.dx;
                _volumeAdjustType = _VolumeAdjustType.media;
                _dragStartDeviceValue = play.volumeNotifier.value.volume
                    .toDouble();
              }
            },
      onVerticalDragUpdate: lockedNotifier.value
          ? null
          : (details) {
              final delta = _dragStartPoint.dy - details.localPosition.dy;

              if (_isAdjustingBrightness) {
                // Adjust brightness
                final target = (_dragStartDeviceValue + delta / 200).clamp(
                  0,
                  1.0,
                );
                context.read<ScreenBrightnessNotifier>().value = target
                    .toDouble();
              } else {
                if (_volumeAdjustType == _VolumeAdjustType.voice) {
                  // Adjust voice
                  final value = (_dragStartDeviceValue + delta).toInt();
                  final newVolume = Volume(
                    volume: value.clamp(Volume.min, Volume.max),
                  );
                  Actions.invoke(context, UpdateVoiceVolumeIntent(newVolume));

                  if (!_canAdjustVoice() ||
                      _farthestX - details.localPosition.dx > 20.0) {
                    _volumeAdjustType = _VolumeAdjustType.media;
                    _dragStartDeviceValue = play.volumeNotifier.value.volume
                        .toDouble();
                    _farthestX = details.localPosition.dx;
                  } else {
                    _farthestX = max(_farthestX, details.localPosition.dx);
                  }
                } else {
                  // Adjust media
                  final value = (_dragStartDeviceValue + delta).toInt();
                  final newVolume = Volume(
                    volume: value.clamp(Volume.min, Volume.max),
                  );
                  Actions.invoke(context, UpdateVolumeIntent(newVolume));

                  if (!_canAdjustVoice()) return;
                  if (details.localPosition.dx - _farthestX > 20.0) {
                    _volumeAdjustType = _VolumeAdjustType.voice;
                    _dragStartDeviceValue = voiceNotifier.value.volume
                        .toDouble();
                    _dragStartPoint = details.localPosition;
                  } else {
                    _farthestX = min(_farthestX, details.localPosition.dx);
                  }
                }
              }
            },
      onVerticalDragEnd: lockedNotifier.value
          ? null
          : (details) {
              if (!_isAdjustingBrightness) {
                // Save volumes
                Actions.invoke(context, UpdateVolumeIntent.save());
                Actions.invoke(context, UpdateVoiceVolumeIntent.save());
              }
            },
      child: ValueListenableBuilder(
        valueListenable: _lockButtonVisibleNotifier,
        builder: (context, visible, child) => Visibility(
          visible: visible,
          child: IconButton.outlined(
            onPressed: () {
              if (lockedNotifier.value) {
                lockedNotifier.value = false;
                _showHUDNotifier.mark();
              } else {
                lockedNotifier.value = true;
                _showHUDNotifier.reset();
              }
            },
            isSelected: lockedNotifier.value,
            icon: Icon(lockedNotifier.value ? Icons.lock : Icons.lock_open),
          ),
        ).padding(right: 18.0).alignment(.centerRight),
      ),
    );
  }

  @override
  void dispose() {
    _showHUDNotifier.removeListener(_onHUDVisibleChanged);
    _lockButtonVisibleNotifier.dispose();
    super.dispose();
  }

  void _onHUDVisibleChanged() {
    if (_showHUDNotifier.value) {
      _lockButtonVisibleNotifier.lockUp('hud');
    } else {
      _lockButtonVisibleNotifier.unlock('hud');
      // If hide HUD isn't caused by lock button, hide button immediately
      // else keep showing lock button for a while
      if (!context.read<ScreenLockedNotifier>().value) {
        _lockButtonVisibleNotifier.reset();
      }
    }
  }

  bool _canAdjustVoice() {
    final status = context.read<CallStatus?>();
    return status == .talking;
  }
}
