import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/utils/business/drag_business.dart';
import 'package:bunga_player/reaction/business.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/screens/player_screen/play_progress_slide_business.dart';
import 'package:bunga_player/voice_call/client/client.dart';

import 'spark_send_controller.dart';

class TouchInteractiveLayer extends StatefulWidget {
  const TouchInteractiveLayer({super.key});

  @override
  State<TouchInteractiveLayer> createState() => _TouchInteractiveLayerState();
}

class _TouchInteractiveLayerState extends State<TouchInteractiveLayer> {
  static const _verticalFactor = 1 / 200.0;

  // Dragging
  DragBusiness? _dragBusiness;

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
      return BungaGestureDetector(
        behavior: .translucent,

        onTap: _lockButtonVisibleNotifier.mark,

        onDoubleTapDragStart: _startSendSpark,
        onDoubleTapDragUpdated: _updateSendSpark,
        onDoubleTapDragEnd: _finishSendSpark,

        child: lockButton,
      );
    }

    return BungaGestureDetector(
      behavior: .translucent,
      onTap: () {
        _showHUDNotifier.value
            ? _showHUDNotifier.reset()
            : _showHUDNotifier.mark();
      },
      onDoubleTap: Actions.handler(context, IndirectToggleIntent()),

      onHorizentalDragStart: _startSlideSeeking,
      onHorizontalDragUpdate: _updateDragBusiness,
      onHorizontalDragEnd: _finishSlideSeeking,
      onHorizontalDragCancel: _cancelSlideSeeking,

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
    }
  }

  void _updateDragBusiness(DragUpdateDetails details) =>
      _dragBusiness?.updatePosition(details.localPosition);

  void _startSlideSeeking(DragStartDetails details) {
    final business = context.read<PlayProgressSlideBusiness>();
    final play = MediaPlayer.i;
    final startPosition = play.positionNotifier.value;
    _dragBusiness = DragBusiness<int>(
      startPosition: details.localPosition,
      orientation: .horizontal,
      startValue: startPosition.inMilliseconds,
      onUpdate: (startValue, distance) {
        final newValue = startValue + distance * 200;
        return business.updateSlide(newValue.milliseconds);
      },
      onEnd: (startValue, distance) {
        final newValue = startValue + distance * 200;
        return business.finishSlide(newValue.milliseconds);
      },
      onCancel: business.cancelSlide,
    );

    business.startSlide(startPosition);
  }

  void _finishSlideSeeking(DragEndDetails details) {
    _dragBusiness!.end(details.localPosition);
    _dragBusiness = null;
  }

  void _cancelSlideSeeking() {
    _dragBusiness?.cancel();
    _dragBusiness = null;
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
      startValue: MediaPlayer.i.volumeNotifier.value.level,
      onUpdate: (startValue, distance) {
        final delta = distance * _verticalFactor;
        final newValue = Volume(level: startValue + delta);
        MediaPlayer.i.volumeNotifier.value = newValue;
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
    context.read<SparkBarVisibilityNotifier>().lockUp('sending');
  }

  void _updateSendSpark(DragUpdateDetails details) {
    _sparkController.updateOffset(details.localPosition);
  }

  void _finishSendSpark(DragEndDetails details) {
    _sparkController.stop();

    context.read<SparkBarVisibilityNotifier>().unlock('sending');
  }
}

class BungaGestureDetector extends SingleChildStatefulWidget {
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

  final GestureDragCancelCallback? onHorizontalDragCancel,
      onVerticalDragCancel,
      onVerticalMultiFingerDragCancel,
      onDoubleTapDragCancel;

  final HitTestBehavior? behavior;

  const BungaGestureDetector({
    super.key,
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
    this.onHorizontalDragCancel,
    this.onVerticalDragCancel,
    this.onVerticalMultiFingerDragCancel,
    this.onDoubleTapDragCancel,
    super.child,
  });

  @override
  State<BungaGestureDetector> createState() => _GestureDetectorState();
}

class _GestureDetectorState extends SingleChildState<BungaGestureDetector> {
  // Double Tap
  Timer? _doubleTapTimer;
  bool _isPotentialDoubleTap = false;
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
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: () {
          if (_isDoubleTapDragging) return;
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
        onHorizontalDragCancel: () {
          if (_isSingleDragging) {
            widget.onHorizontalDragCancel?.call();
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
        onVerticalDragCancel: () {
          if (_isSingleDragging) {
            widget.onVerticalDragCancel?.call();
            _isSingleDragging = false;
          }

          if (_isMultiFingerDragging) {
            widget.onVerticalMultiFingerDragCancel?.call();
            _isMultiFingerDragging = false;
          }
        },

        onLongPressStart: (details) {
          if (!_isPotentialDoubleTap) return;

          _isPotentialDoubleTap = false;
          _doubleTapTimer?.cancel();

          _isDoubleTapDragging = true;
          widget.onDoubleTapDragStart?.call(
            DragStartDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition,
            ),
          );
        },
        onLongPressMoveUpdate: (details) {
          if (!_isDoubleTapDragging) return;

          widget.onDoubleTapDragUpdated?.call(
            DragUpdateDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition,
            ),
          );
        },
        onLongPressEnd: (details) {
          if (!_isDoubleTapDragging) return;

          _isDoubleTapDragging = false;
          widget.onDoubleTapDragEnd?.call(
            DragEndDetails(
              globalPosition: details.globalPosition,
              localPosition: details.localPosition,
              velocity: details.velocity,
            ),
          );
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
      return;
    }

    if (_activePointers == 0) {
      _isPotentialMultiFingerDrag = false;
    }

    if (!_isPotentialDoubleTap) {
      // First tap detected
      _isPotentialDoubleTap = true;
      _doubleTapTimer = Timer(kDoubleTapTimeout + kLongPressTimeout, () {
        _isPotentialDoubleTap = false;
      });
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _activePointers--;

    if (_isDoubleTapDragging && _activePointers == 0) {
      widget.onDoubleTapDragCancel?.call();
      _isDoubleTapDragging = false;
      return;
    }

    if (_activePointers == 0) {
      _isPotentialMultiFingerDrag = false;
    }
  }
}
