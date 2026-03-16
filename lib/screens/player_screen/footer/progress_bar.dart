import 'package:bunga_player/utils/business/drag_business.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/business/animation_builder.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:bunga_player/screens/widgets/slider_dense_track_shape.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({super.key});

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  bool _isHovered = false;
  bool _isDragging = false;

  DragBusiness? _dragBusiness;

  @override
  void initState() {
    super.initState();

    if (!kIsDesktop) {
      // always show max size when not desktop
      _isHovered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<BusyStateNotifier>().isBusy;
    if (isBusy) return const LinearProgressIndicator().center();

    final slider = _ProgressSlider(
      onDragStart: () => _isDragging = true,
      onDragEnd: () => _isDragging = false,
    );

    final animatedSlider = ValueListenableBuilder(
      valueListenable: MediaPlayer.i.isBufferingNotifier,
      builder: (context, amIBuffering, child) =>
          Selector<WatcherPendingIdsNotifier?, bool>(
            selector: (context, notifier) =>
                notifier?.value.isNotEmpty ?? false,
            builder: (context, hasPending, child) {
              final showBuffering = amIBuffering || hasPending;

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
                    overlayShape: SliderComponentShape.noOverlay,
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
      final player = MediaPlayer.i;
      return LayoutBuilder(
        builder: (context, constraints) {
          double getDelta(double distance) {
            final width = constraints.maxWidth;
            final duration = player.durationNotifier.value;
            final deltaD = duration * (distance / width);
            return deltaD.inMilliseconds.toDouble();
          }

          final slideSeekingBusiness = context
              .read<PlayProgressSlideBusiness>();

          return GestureDetector(
            behavior: .opaque,
            onHorizontalDragStart: (details) {
              final initValue = player.positionNotifier.value.inMilliseconds
                  .toDouble();

              _dragBusiness = DragBusiness<double>(
                startPosition: details.localPosition,
                orientation: .horizontal,
                startValue: initValue,
                onUpdate: (startValue, distance) {
                  final delta = getDelta(distance);
                  final newPosition = startValue + delta;
                  slideSeekingBusiness.updateSlide(newPosition);
                },
                onEnd: (startValue, distance) {
                  final delta = getDelta(distance);
                  final newPosition = startValue + delta;
                  slideSeekingBusiness.finishSlide(newPosition);
                },
                onCancel: slideSeekingBusiness.cancelSlide,
              );

              slideSeekingBusiness.startSlide(initValue);
            },
            onHorizontalDragUpdate: (details) =>
                _dragBusiness!.updatePosition(details.localPosition),
            onHorizontalDragEnd: (details) {
              _dragBusiness!.end(details.localPosition);
              _dragBusiness = null;
            },
            onHorizontalDragCancel: () {
              _dragBusiness!.cancel();
              _dragBusiness = null;
            },
            child: IgnorePointer(child: animatedSlider),
          );
        },
      );
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

class _ProgressSlider extends StatelessWidget {
  final VoidCallback? onDragStart, onDragEnd;
  const _ProgressSlider({this.onDragStart, this.onDragEnd});

  @override
  Widget build(BuildContext context) {
    final player = MediaPlayer.i;
    final business = context.read<PlayProgressSlideBusiness>();

    return ListenableBuilder(
      listenable: Listenable.merge([
        player.durationNotifier,
        player.bufferNotifier,
        business.positionNotifier,
      ]),
      builder: (context, child) {
        final duration = player.durationNotifier.value.inMilliseconds
            .toDouble();
        final buffer = player.bufferNotifier.value.inMilliseconds.toDouble();
        final position = business.positionNotifier.value;

        return Slider(
          value: position.clamp(0, duration),
          secondaryTrackValue: buffer.clamp(0, duration).toDouble(),
          max: duration.toDouble(),
          // avoid control by left / right key
          focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
          label: Duration(milliseconds: position.toInt()).hhmmss,
          onChangeStart: (value) {
            business.startSlide(value);
            onDragStart?.call();
          },
          onChanged: business.updateSlide,
          onChangeEnd: (value) {
            business.finishSlide(value);
            onDragEnd?.call();
          },
        );
      },
    );
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
