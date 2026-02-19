import 'dart:async';
import 'dart:math';

import 'package:bunga_player/screens/player_screen/player_widget/interactive_layer/spark_business.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/global_business.dart';

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

  // Spark
  late final SparkSendController _sparkController;

  @override
  void initState() {
    super.initState();
    _showHUDNotifier.addListener(_onHUDVisibleChanged);
    _sparkController = SparkSendController(context);
  }

  @override
  void dispose() {
    _showHUDNotifier.removeListener(_onHUDVisibleChanged);
    _lockButtonVisibleNotifier.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final play = getIt<PlayService>();
    final voiceNotifier = context.read<AgoraClient>().volumeNotifier;

    final lockedNotifier = context.watch<ScreenLockedNotifier>();

    final lockButton = ValueListenableBuilder(
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
    );
    if (lockedNotifier.value) {
      return GestureDetector(
        behavior: .translucent,
        onTap: _lockButtonVisibleNotifier.mark,
        child: lockButton,
      );
    }

    return _GestureDetector(
      behavior: .translucent,
      onTap: () {
        _showHUDNotifier.value
            ? _showHUDNotifier.reset()
            : _showHUDNotifier.mark();
      },
      onDoubleTap: Actions.handler(context, ToggleIntent()),

      onHorizentalDragStart: (details) {
        _showHUDNotifier.lockUp('drag');

        _dragStartPoint = details.localPosition;
        _dargStartVideoPosition = play.positionNotifier.value;

        Actions.maybeInvoke(context, SeekStartIntent());

        _isPlayingBeforeDrag = play.playStatusNotifier.value.isPlaying;
        play.pause();
      },
      onHorizontalDragUpdate: (details) {
        final xOffset = details.localPosition.dx - _dragStartPoint.dx;
        final positionOffset = Duration(seconds: xOffset.toInt() ~/ 5);
        play.seek(_dargStartVideoPosition + positionOffset);
      },
      onHorizontalDragEnd: (details) {
        final xOffset = details.localPosition.dx - _dragStartPoint.dx;
        final positionOffset = Duration(seconds: xOffset.toInt() ~/ 5);

        if (_isPlayingBeforeDrag) play.play();
        Actions.invoke<SeekIntent>(
          context,
          SeekEndIntent(_dargStartVideoPosition + positionOffset),
        );

        context.read<ShouldShowHUDNotifier>().unlock('drag');
      },

      onVerticalDragStart: (details) {
        _dragStartPoint = details.localPosition;

        _isAdjustingBrightness = _dragStartPoint.dx < context.size!.width / 2;

        if (_isAdjustingBrightness) {
          // Adjust brightness
          _dragStartDeviceValue = context
              .read<ScreenBrightnessNotifier>()
              .value;
        } else {
          // Adjust volume
          _farthestX = _dragStartPoint.dx;
          _volumeAdjustType = _VolumeAdjustType.media;
          _dragStartDeviceValue = play.volumeNotifier.value.volume.toDouble();
        }
      },
      onVerticalDragUpdate: (details) {
        final delta = _dragStartPoint.dy - details.localPosition.dy;

        if (_isAdjustingBrightness) {
          // Adjust brightness
          final target = (_dragStartDeviceValue + delta / 200).clamp(0, 1.0);
          context.read<ScreenBrightnessNotifier>().value = target.toDouble();
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
          Actions.invoke(context, UpdateVolumeIntent.save());
          Actions.invoke(context, UpdateVoiceVolumeIntent.save());
        }
      },

      onDoubleTapDragStart: (details) {
        _sparkController.start(details.localPosition);
      },
      onDoubleTapDragUpdated: (details) {
        _sparkController.updateOffset(details.localPosition);
      },
      onDoubleTapDragEnd: (details) {
        _sparkController.stop();
      },

      child: lockButton,
    );
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

class _GestureDetector extends SingleChildStatefulWidget {
  final GestureTapCallback? onTap, onDoubleTap;

  final GestureDragStartCallback? onHorizentalDragStart,
      onVerticalDragStart,
      onDoubleTapDragStart;

  final GestureDragUpdateCallback? onHorizontalDragUpdate,
      onVerticalDragUpdate,
      onDoubleTapDragUpdated;

  final GestureDragEndCallback? onHorizontalDragEnd,
      onVerticalDragEnd,
      onDoubleTapDragEnd;

  final HitTestBehavior? behavior;

  const _GestureDetector({
    this.onTap,
    this.onDoubleTap,
    this.onHorizentalDragStart,
    this.onVerticalDragStart,
    this.onDoubleTapDragStart,
    this.onHorizontalDragUpdate,
    this.onVerticalDragUpdate,
    this.onDoubleTapDragUpdated,
    this.onHorizontalDragEnd,
    this.onVerticalDragEnd,
    this.onDoubleTapDragEnd,
    this.behavior,
    super.child,
  });

  @override
  State<_GestureDetector> createState() => _GestureDetectorState();
}

class _GestureDetectorState extends SingleChildState<_GestureDetector> {
  // Configuration Constants
  static const doubleTapTimeout = Duration(milliseconds: 300);

  // business
  Timer? _doubleTapTimer;
  bool _isPotentialDoubleTap = false;
  bool _isPotentialDoubleTapDragging = false;
  bool _isDoubleTapDragging = false;
  bool _isSingleDragging = false;

  @override
  void dispose() {
    _doubleTapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: () {
          if (!_isPotentialDoubleTapDragging) widget.onTap?.call();
        },
        onDoubleTap: widget.onDoubleTap,

        onHorizontalDragStart: (details) {
          if (!_isDoubleTapDragging) {
            _isSingleDragging = true;
            widget.onHorizentalDragStart?.call(details);
          }
        },
        onHorizontalDragUpdate: (details) {
          if (_isSingleDragging) {
            widget.onHorizontalDragUpdate?.call(details);
          }
        },
        onHorizontalDragEnd: (details) {
          if (_isSingleDragging) {
            widget.onHorizontalDragEnd?.call(details);
            _isSingleDragging = false;
          }
        },

        onVerticalDragStart: (details) {
          if (!_isDoubleTapDragging) {
            _isSingleDragging = true;
            widget.onVerticalDragStart?.call(details);
          }
        },
        onVerticalDragUpdate: (details) {
          if (_isSingleDragging) {
            widget.onVerticalDragUpdate?.call(details);
          }
        },
        onVerticalDragEnd: (details) {
          if (_isSingleDragging) {
            widget.onVerticalDragEnd?.call(details);
            _isSingleDragging = false;
          }
        },

        child: child,
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_isPotentialDoubleTap) {
      // Second tap detected!
      // Now we wait: if the user moves before lifting, it's a Double-Tap-Drag.
      _isPotentialDoubleTapDragging = true;
      _doubleTapTimer?.cancel();
      _isPotentialDoubleTap = false;
    } else {
      // First tap detected
      _isPotentialDoubleTap = true;
      _doubleTapTimer = Timer(doubleTapTimeout, () {
        _isPotentialDoubleTap = false;
      });
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_isPotentialDoubleTapDragging) {
      _isPotentialDoubleTapDragging = false;
      _isDoubleTapDragging = true;

      final startDetails = DragStartDetails(
        sourceTimeStamp: event.timeStamp,
        globalPosition: event.position,
        localPosition: event.localPosition,
        kind: event.kind,
      );
      widget.onDoubleTapDragStart?.call(startDetails);
    }
    if (_isDoubleTapDragging) {
      final updateDetails = DragUpdateDetails(
        sourceTimeStamp: event.timeStamp,
        delta: event.delta,
        globalPosition: event.position,
        localPosition: event.localPosition,
      );
      widget.onDoubleTapDragUpdated?.call(updateDetails);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_isDoubleTapDragging) {
      final endDetails = DragEndDetails(
        globalPosition: event.position,
        localPosition: event.localPosition,
      );
      widget.onDoubleTapDragEnd?.call(endDetails);

      _isDoubleTapDragging = false;
    }
    _isPotentialDoubleTapDragging = false;
  }
}
