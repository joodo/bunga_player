import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/utils/business/drag_business.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/screens/player_screen/player_widget/interactive_layer/spark_send_controller.dart';
import 'package:bunga_player/voice_call/client/client.dart';

class TouchInteractiveLayer extends StatefulWidget {
  const TouchInteractiveLayer({super.key});

  @override
  State<TouchInteractiveLayer> createState() => _TouchInteractiveLayerState();
}

class _TouchInteractiveLayerState extends State<TouchInteractiveLayer> {
  static const _verticalFactor = 1 / 200.0;

  // Dragging
  DragBusiness? _dragBusiness;

  // Horizontal drag
  bool _isPlayingBeforeDrag = false;

  // Vertical drag
  bool _isDraggingLeftSide = false;

  // Screen locking
  final _lockButtonVisibleNotifier = AutoResetNotifier(
    const Duration(seconds: 5),
  )..mark();
  late final _showHUDNotifier = context.read<ShouldShowHUDNotifier>();

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
    final lockedNotifier = context.watch<ScreenLockedNotifier>();
    final lockButton = ValueListenableBuilder(
      valueListenable: _lockButtonVisibleNotifier,
      builder: (context, visible, child) => Visibility(
        visible: visible,
        child: lockedNotifier.value
            ? IconButton.filled(
                onPressed: () {
                  lockedNotifier.value = false;
                  _showHUDNotifier.mark();
                  context.read<AdjustIndicatorEvent>().fire(.lockScreen);
                },
                icon: const Icon(Icons.lock),
              )
            : IconButton.outlined(
                onPressed: () {
                  lockedNotifier.value = true;
                  _showHUDNotifier.reset();
                  context.read<AdjustIndicatorEvent>().fire(.lockScreen);
                },
                icon: Icon(Icons.lock_open),
              ),
      ).padding(right: 18.0).alignment(.centerRight),
    );
    if (lockedNotifier.value) {
      return _GestureDetector(
        behavior: .translucent,

        onTap: _lockButtonVisibleNotifier.mark,

        onDoubleTapDragStart: _startSendSpark,
        onDoubleTapDragUpdated: _updateSendSpark,
        onDoubleTapDragEnd: _finishSendSpark,

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
      onDoubleTap: Actions.handler(context, SetPlaybackIntent.toggle()),

      onHorizentalDragStart: _startSlideSeeking,
      onHorizontalDragUpdate: _updateDragBusiness,
      onHorizontalDragEnd: _finishSlideSeeking,

      onVerticalDragStart: (details) {
        _isDraggingLeftSide = _isLeftScreen(details.localPosition);
        _isDraggingLeftSide
            ? _startAdjustBrightness(details)
            : _startAdjustVolume(details);
      },
      onVerticalDragUpdate: _updateDragBusiness,
      onVerticalDragEnd: (details) {
        _dragBusiness = null;
        if (!_isDraggingLeftSide) {
          Actions.invoke(context, FinishUpdateVolumeIntent());
        }
      },

      onVerticalMultiFingerDragStart: (details) {
        // Check if voice volume changable
        final action =
            Actions.maybeFind<UpdateVoiceVolumeIntent>(context)
                as UpdateVoiceVolumeAction?;
        final isEnabled =
            action?.isEnabled(UpdateVoiceVolumeIntent(Volume.max), context) ==
            true;
        if (!isEnabled) {
          _dragBusiness = null;
          return;
        }

        _isDraggingLeftSide = _isLeftScreen(details.localPosition);
        _isDraggingLeftSide
            ? _startAdjustMediaVolume(details)
            : _startAdjustVoiceVolume(details);
      },
      onVerticalMultiFingerDragUpdate: _updateDragBusiness,
      onVerticalMultiFingerDragEnd: (details) {
        if (_dragBusiness != null) {
          _dragBusiness = null;
          if (!_isDraggingLeftSide) {
            Actions.maybeInvoke(context, FinishUpdateVoiceVolumeIntent());
          }
        }
      },

      onDoubleTapDragStart: _startSendSpark,
      onDoubleTapDragUpdated: _updateSendSpark,
      onDoubleTapDragEnd: _finishSendSpark,

      child: lockButton,
    );
  }

  bool _isLeftScreen(Offset position) => position.dx < context.size!.width / 2;

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

  void _updateDragBusiness(DragUpdateDetails details) =>
      _dragBusiness?.updatePosition(details.localPosition);

  void _startSlideSeeking(DragStartDetails details) {
    context.read<ShouldShowHUDNotifier>().lockUp('slide seeking');

    final play = getIt<MediaPlayer>();
    _dragBusiness = DragBusiness(
      startPosition: details.localPosition,
      orientation: .horizontal,
      startValue: play.positionNotifier.value,
      onUpdate: (startValue, distance) {
        final delta = Duration(milliseconds: (distance * 200).round());
        return play.seek(startValue + delta);
      },
    );

    Actions.maybeInvoke(context, SeekStartIntent());

    _isPlayingBeforeDrag = play.playStatusNotifier.value.isPlaying;
    play.pause();
  }

  void _finishSlideSeeking(DragEndDetails details) {
    final action =
        _dragBusiness!.updatePosition(details.localPosition) as Future;
    action.then((_) {
      if (_isPlayingBeforeDrag) getIt<MediaPlayer>().play();
      if (mounted) Actions.maybeInvoke(context, SeekEndIntent());
    });

    _dragBusiness = null;
    context.read<ShouldShowHUDNotifier>().unlock('slide seeking');
  }

  void _startAdjustVolume(DragStartDetails details) {
    _dragBusiness = DragBusiness(
      startPosition: details.localPosition,
      orientation: .vertical,
      startValue: context.read<MediaVolumeNotifier>().value.level,
      onUpdate: (startValue, distance) {
        final delta = distance * _verticalFactor;
        final newVolume = Volume(level: startValue + delta);
        Actions.invoke(context, UpdateVolumeIntent(newVolume));
        context.read<AdjustIndicatorEvent>().fire(.volume);
      },
    );
  }

  void _startAdjustBrightness(DragStartDetails details) {
    _dragBusiness = DragBusiness(
      startPosition: details.localPosition,
      orientation: .vertical,
      startValue: context.read<ScreenBrightnessNotifier>().value,
      onUpdate: (startValue, distance) {
        final delta = distance * _verticalFactor;
        final target = (startValue + delta).clamp(0, 1.0);
        context.read<ScreenBrightnessNotifier>().value = target.toDouble();
        context.read<AdjustIndicatorEvent>().fire(.brightness);
      },
    );
  }

  void _startAdjustMediaVolume(DragStartDetails details) {
    _dragBusiness = DragBusiness(
      startPosition: details.localPosition,
      orientation: .vertical,
      startValue: getIt<MediaPlayer>().volumeNotifier.value.level,
      onUpdate: (startValue, distance) {
        final delta = distance * _verticalFactor;
        final newValue = Volume(level: startValue + delta);
        getIt<MediaPlayer>().volumeNotifier.value = newValue;
        context.read<AdjustIndicatorEvent>().fire(.mediaVolume);
      },
    );
  }

  void _startAdjustVoiceVolume(DragStartDetails details) {
    _dragBusiness = DragBusiness(
      startPosition: details.localPosition,
      orientation: .vertical,
      startValue: context.read<VoiceCallClient>().volumeNotifier.value.level,
      onUpdate: (startValue, distance) {
        final delta = distance * _verticalFactor;
        final newValue = Volume(level: startValue + delta);
        Actions.invoke(context, UpdateVoiceVolumeIntent(newValue));
        context.read<AdjustIndicatorEvent>().fire(.voiceVolume);
      },
    );
  }

  void _startSendSpark(DragStartDetails details) {
    _sparkController.start(details.localPosition);
    _lockButtonVisibleNotifier.reset();
  }

  void _updateSendSpark(DragUpdateDetails details) {
    _sparkController.updateOffset(details.localPosition);
  }

  void _finishSendSpark(DragEndDetails details) {
    _sparkController.stop();
  }
}

class _GestureDetector extends SingleChildStatefulWidget {
  final GestureTapCallback? onTap, onDoubleTap;

  final GestureDragStartCallback? onHorizentalDragStart,
      onVerticalDragStart,
      onVerticalMultiFingerDragStart,
      onDoubleTapDragStart;

  final GestureDragUpdateCallback? onHorizontalDragUpdate,
      onVerticalDragUpdate,
      onVerticalMultiFingerDragUpdate,
      onDoubleTapDragUpdated;

  final GestureDragEndCallback? onHorizontalDragEnd,
      onVerticalDragEnd,
      onVerticalMultiFingerDragEnd,
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
    this.onVerticalMultiFingerDragStart,
    this.onVerticalMultiFingerDragUpdate,
    this.onVerticalMultiFingerDragEnd,
    super.child,
  });

  @override
  State<_GestureDetector> createState() => _GestureDetectorState();
}

class _GestureDetectorState extends SingleChildState<_GestureDetector> {
  // Double Tap
  Timer? _doubleTapTimer;
  bool _isPotentialDoubleTap = false;
  bool _isPotentialDoubleTapDragging = false;
  bool _isDoubleTapDragging = false;
  bool _isSingleDragging = false;

  // Two Pointers Drag
  int _activePointers = 0;
  bool _isPotentialMultiFingerDrag = false;
  bool _isMultiFingerDragging = false;

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
          if (_isPotentialDoubleTapDragging) return;
          widget.onTap?.call();
        },
        onDoubleTap: () {
          if (_isDoubleTapDragging) return;
          widget.onDoubleTap?.call();
        },

        onHorizontalDragStart: (details) {
          if (_isDoubleTapDragging || _isPotentialMultiFingerDrag) return;

          _isSingleDragging = true;

          widget.onHorizentalDragStart?.call(details);
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
          if (_isDoubleTapDragging) return;

          if (_isPotentialMultiFingerDrag) {
            _isMultiFingerDragging = true;
            widget.onVerticalMultiFingerDragStart?.call(details);
          } else {
            _isSingleDragging = true;
            widget.onVerticalDragStart?.call(details);
          }
        },
        onVerticalDragUpdate: (details) {
          if (_isSingleDragging) {
            widget.onVerticalDragUpdate?.call(details);
          }

          if (_isMultiFingerDragging) {
            widget.onVerticalMultiFingerDragUpdate?.call(details);
          }
        },
        onVerticalDragEnd: (details) {
          if (_isSingleDragging) {
            widget.onVerticalDragEnd?.call(details);
            _isSingleDragging = false;
          }

          if (_isMultiFingerDragging) {
            widget.onVerticalMultiFingerDragEnd?.call(details);
            _isMultiFingerDragging = false;
          }
        },

        child: child,
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers++;

    if (_activePointers > 1) {
      // Transition to multi-finger mode
      _isPotentialMultiFingerDrag = true;
      _isSingleDragging = false;
      _isPotentialDoubleTap = false;
      _doubleTapTimer?.cancel();
      return;
    }

    if (_isPotentialDoubleTap) {
      // Second tap detected!
      // Now wait: if the user moves before lifting, it's a Double-Tap-Drag.
      _isPotentialDoubleTapDragging = true;
      _doubleTapTimer?.cancel();
      _isPotentialDoubleTap = false;
    } else {
      // First tap detected
      _isPotentialDoubleTap = true;
      _doubleTapTimer = Timer(kDoubleTapTimeout, () {
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
    _activePointers--;

    if (_isDoubleTapDragging && _activePointers == 0) {
      final endDetails = DragEndDetails(
        globalPosition: event.position,
        localPosition: event.localPosition,
      );
      widget.onDoubleTapDragEnd?.call(endDetails);

      _isDoubleTapDragging = false;
    }

    if (_activePointers == 0) {
      _isPotentialMultiFingerDrag = false;
      _isPotentialDoubleTapDragging = false;
    }
  }
}
