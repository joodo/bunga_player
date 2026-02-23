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
import 'package:bunga_player/screens/player_screen/player_widget/interactive_layer/spark_business.dart';
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
    final play = getIt<MediaPlayer>();

    final indicatorEvent = context.read<AdjustIndicatorEvent>();

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
            indicatorEvent.fire(.lockScreen);
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
      },
      onHorizontalDragUpdate: (details) {
        _dragBusiness!.updatePosition(details.localPosition);
      },
      onHorizontalDragEnd: (details) {
        final action =
            _dragBusiness!.updatePosition(details.localPosition) as Future;
        action.then((_) {
          if (_isPlayingBeforeDrag) play.play();
          if (context.mounted) Actions.maybeInvoke(context, SeekEndIntent());
        });

        _dragBusiness = null;
        context.read<ShouldShowHUDNotifier>().unlock('drag');
      },

      onVerticalDragStart: (details) {
        final startPosition = details.localPosition;

        _isDraggingLeftSide = _isLeftScreen(startPosition);

        _dragBusiness = DragBusiness(
          startPosition: startPosition,
          orientation: .vertical,
          startValue: _isDraggingLeftSide
              ? context.read<ScreenBrightnessNotifier>().value
              : context.read<MediaVolumeNotifier>().value.level,
          onUpdate: _isDraggingLeftSide
              ? (startValue, distance) {
                  final delta = distance * _verticalFactor;
                  final target = (startValue + delta).clamp(0, 1.0);
                  context.read<ScreenBrightnessNotifier>().value = target
                      .toDouble();
                  indicatorEvent.fire(.brightness);
                }
              : (startValue, distance) {
                  final delta = distance * _verticalFactor;
                  final newVolume = Volume(level: startValue + delta);
                  Actions.invoke(context, UpdateVolumeIntent(newVolume));
                  indicatorEvent.fire(.volume);
                },
        );
      },
      onVerticalDragUpdate: (details) =>
          _dragBusiness!.updatePosition(details.localPosition),
      onVerticalDragEnd: (details) {
        _dragBusiness = null;
        if (!_isDraggingLeftSide) {
          Actions.invoke(context, FinishUpdateVolumeIntent());
        }
      },

      onVerticalMultiFingerDragStart: (details) {
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

        final startPosition = details.localPosition;
        _isDraggingLeftSide = _isLeftScreen(startPosition);
        final mediaVolumeNotifer = getIt<MediaPlayer>().volumeNotifier;
        _dragBusiness = DragBusiness(
          startPosition: startPosition,
          orientation: .vertical,
          startValue: _isDraggingLeftSide
              ? mediaVolumeNotifer.value.level
              : context.read<VoiceCallClient>().volumeNotifier.value.level,
          onUpdate: _isDraggingLeftSide
              ? (startValue, distance) {
                  final delta = distance * _verticalFactor;
                  final newValue = Volume(level: startValue + delta);
                  mediaVolumeNotifer.value = newValue;
                  indicatorEvent.fire(.mediaVolume);
                }
              : (startValue, distance) {
                  final delta = distance * _verticalFactor;
                  final newValue = Volume(level: startValue + delta);
                  Actions.invoke(context, UpdateVoiceVolumeIntent(newValue));
                  indicatorEvent.fire(.voiceVolume);
                },
        );
      },
      onVerticalMultiFingerDragUpdate: (details) =>
          _dragBusiness?.updatePosition(details.localPosition),
      onVerticalMultiFingerDragEnd: (details) {
        if (_dragBusiness != null) {
          _dragBusiness = null;
          if (!_isDraggingLeftSide) {
            Actions.maybeInvoke(context, FinishUpdateVoiceVolumeIntent());
          }
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
