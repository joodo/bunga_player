import 'package:bunga_player/play_sync/business.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/business/animation_builder.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:bunga_player/screens/widgets/slider_dense_track_shape.dart';
import 'package:styled_widget/styled_widget.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({super.key});

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  bool _isHovered = false;
  bool _isDragging = false;

  final _sliderKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // always show max size when not desktop
    if (!kIsDesktop) _isHovered = true;
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<BusyStateNotifier>().isBusy;
    if (isBusy) return const LinearProgressIndicator().center();

    final slider = _ProgressSlider(
      key: _sliderKey,
      onDragStart: () => _isDragging = true,
      onDragEnd: () => _isDragging = false,
    );

    final animatedSlider = ValueListenableBuilder(
      valueListenable: getIt<MediaPlayer>().isBufferingNotifier,
      builder: (context, amIBuffering, child) =>
          Selector<WatcherBufferingStatusNotifier?, bool>(
            selector: (context, notifier) => notifier?.hasBuffering ?? false,
            builder: (context, hasBuffering, child) {
              final showBuffering = amIBuffering || hasBuffering;

              return TweenAnimationBuilder(
                tween: Tween<double>(
                  end: _isHovered || _isDragging ? 1.0 : 0.0,
                ),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInCubic,
                builder: (context, hoveredValue, child) {
                  final sliderThemeData = SliderThemeData(
                    thumbColor: Theme.of(context).colorScheme.primary,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 8 * hoveredValue,
                    ),
                    trackHeight: 2 + 2 * hoveredValue,
                    trackShape: SliderDenseTrackShape(),
                    showValueIndicator: .onDrag,
                  );

                  if (!showBuffering) {
                    return SliderTheme(data: sliderThemeData, child: child!);
                  } else {
                    return InfiniteAnimationBuilder(
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, pulseValue, child) => SliderTheme(
                        data: sliderThemeData.copyWith(
                          thumbShape: _PulseThumbShape(
                            thumbRadius: 8.0 * hoveredValue,
                            isBuffering: true,
                            pulseSizeFactor: pulseValue,
                          ),
                        ),
                        child: child!,
                      ),
                      child: child,
                    );
                  }
                },
                child: child,
              );
            },
            child: child,
          ),
      child: slider,
    );

    if (!kIsDesktop) {
      return animatedSlider;
    } else {
      return MouseRegion(
        onEnter: (event) => setState(() {
          _isHovered = true;
        }),
        onExit: (event) => setState(() {
          _isHovered = false;
        }),
        child: animatedSlider,
      );
    }
  }
}

class _ProgressSlider extends StatefulWidget {
  final VoidCallback? onDragStart, onDragEnd;
  const _ProgressSlider({super.key, this.onDragStart, this.onDragEnd});

  @override
  State<_ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<_ProgressSlider> {
  // Player
  final _player = getIt<MediaPlayer>();
  late final _playerPositionNotifier = _player.positionNotifier;

  // Current position
  final _positionNotifier = ValueNotifier<double>(0);
  void _followPlayerPosition() {
    _positionNotifier.value = _playerPositionNotifier.value.inMilliseconds
        .toDouble();
  }

  // Drag business
  bool _isPlayingBeforeDraggingSlider = false;

  @override
  void initState() {
    super.initState();
    _playerPositionNotifier.addListener(_followPlayerPosition);
    _followPlayerPosition();
  }

  @override
  void dispose() {
    _playerPositionNotifier.removeListener(_followPlayerPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _player.durationNotifier,
        _player.bufferNotifier,
        _positionNotifier,
      ]),
      builder: (context, child) {
        final duration = _player.durationNotifier.value.inMilliseconds
            .toDouble();
        final buffer = _player.bufferNotifier.value.inMilliseconds.toDouble();
        final position = _positionNotifier.value;

        return Slider(
          value: position.clamp(0, duration),
          secondaryTrackValue: buffer.clamp(0, duration).toDouble(),
          max: duration.toDouble(),
          // avoid control by left / right key
          focusNode: FocusNode(canRequestFocus: false),
          label: Duration(milliseconds: position.toInt()).hhmmss,
          onChangeStart: _onChangeStart,
          onChanged: _onChanged,
          onChangeEnd: _onChangeEnd,
        );
      },
    );
  }

  void _onChangeStart(double value) {
    _playerPositionNotifier.removeListener(_followPlayerPosition);

    Actions.maybeInvoke(context, SeekStartIntent());

    _isPlayingBeforeDraggingSlider = _player.playStatusNotifier.value.isPlaying;
    _player.pause();

    final pos = Duration(milliseconds: value.toInt());
    _player.seek(pos);

    _positionNotifier.value = value;

    widget.onDragStart?.call();

    final showHUDNotifier = context.read<ShouldShowHUDNotifier>();
    showHUDNotifier.lockUp('drag');
  }

  void _onChanged(double value) {
    if (_player.durationNotifier.value == Duration.zero) return;

    final pos = Duration(milliseconds: value.toInt());
    _player.seek(pos);

    _positionNotifier.value = value;
  }

  void _onChangeEnd(double value) {
    if (_isPlayingBeforeDraggingSlider) _player.play();

    final pos = Duration(milliseconds: value.toInt());
    _player.seek(pos).then((_) {
      if (!mounted) return;
      Actions.maybeInvoke(context, SeekEndIntent());
    });

    _playerPositionNotifier.addListener(_followPlayerPosition);

    _positionNotifier.value = value;

    widget.onDragEnd?.call();

    final showHUDNotifier = context.read<ShouldShowHUDNotifier>();
    showHUDNotifier.unlock('drag');
  }
}

class _PulseThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final bool isBuffering;
  final double pulseSizeFactor;

  _PulseThumbShape({
    required this.thumbRadius,
    required this.isBuffering,
    required this.pulseSizeFactor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Color thumbColor = sliderTheme.thumbColor ?? Colors.blue;

    // Draw the pulsing aura (expanding ring)
    if (isBuffering) {
      final double auraRadius =
          thumbRadius + (pulseSizeFactor * 14.0); // Expand outward
      final double opacity = (1.0 - pulseSizeFactor).clamp(
        0.0,
        1.0,
      ); // Fade out

      final auraPaint = Paint()
        ..color = thumbColor.withAlpha((opacity * 200).toInt())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, auraRadius, auraPaint);
    }

    // Add a slight shadow for depth
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(100)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(
      Offset(center.dx, center.dy + 1),
      thumbRadius,
      shadowPaint,
    );

    // Draw the main static thumb
    final mainPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, mainPaint);
  }
}
