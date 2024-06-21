import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/screens/widgets/slider_dense_track_shape.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoProgressIndicator extends StatefulWidget {
  const VideoProgressIndicator({super.key});

  @override
  State<VideoProgressIndicator> createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  bool _isHovered = false;
  bool _isChanging = false;
  double _slideThemeLerpT = 0;

  @override
  Widget build(BuildContext context) {
    final tweenAnimation = Consumer3<PlayPosition, PlayDuration, PlayBuffer>(
      builder: (context, position, duration, buffer, child) {
        final slider = Slider(
          value: position.value.inMilliseconds
              .clamp(0, duration.value.inMilliseconds)
              .toDouble(),
          secondaryTrackValue: buffer.value.inMilliseconds
              .clamp(0, duration.value.inMilliseconds)
              .toDouble(),
          max: duration.value.inMilliseconds.toDouble(),
          focusNode: FocusNode(canRequestFocus: false),
          label: position.value.hhmmss,
          onChangeStart: (value) {
            setState(() {
              _isChanging = true;
              _slideThemeLerpT = 1.0;
            });
            Actions.invoke(
              context,
              StartDraggingProgressIntent(
                Duration(milliseconds: value.toInt()),
              ),
            );
          },
          onChanged: (double value) {
            Actions.maybeInvoke(
              context,
              DraggingProgressIntent(
                Duration(milliseconds: value.toInt()),
              ),
            );
          },
          onChangeEnd: (value) {
            setState(() {
              _isChanging = false;
              if (!_isHovered) _slideThemeLerpT = 0;
            });

            Actions.maybeInvoke(
              context,
              FinishDraggingProgressIntent(
                Duration(milliseconds: value.toInt()),
              ),
            );
          },
        );

        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: _slideThemeLerpT),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInCubic,
          builder: (context, value, child) {
            return Selector<PlayIsBuffering, bool>(
              selector: (context, notifier) => notifier.value,
              builder: (context, isBuffering, _) {
                if (!isBuffering) {
                  return SliderTheme(
                    data: SliderThemeData(
                      thumbColor: Theme.of(context).colorScheme.primary,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 8 * value),
                      trackHeight: 2 + 2 * value,
                      trackShape: SliderDenseTrackShape(),
                      showValueIndicator: ShowValueIndicator.always,
                    ),
                    child: child!,
                  );
                }

                double factor = duration.value.inMilliseconds != 0
                    ? position.value.inMilliseconds /
                        duration.value.inMilliseconds
                    : 0;
                factor *= 2;
                factor -= 1;

                final size = 4 * value;

                final bufferingMask = Align(
                  alignment: Alignment(factor, 0),
                  child: SizedBox.shrink(
                    child: OverflowBox(
                      maxHeight: size,
                      maxWidth: size,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.butt,
                      ),
                    ),
                  ),
                );

                return SliderTheme(
                  data: SliderThemeData(
                    thumbColor: Theme.of(context).colorScheme.inversePrimary,
                    thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 8 * value),
                    trackHeight: 2 + 2 * value,
                    trackShape: SliderDenseTrackShape(),
                    showValueIndicator: ShowValueIndicator.always,
                  ),
                  child: Stack(
                    children: [
                      child!,
                      bufferingMask,
                    ],
                  ),
                );
              },
            );
          },
          child: slider,
        );
      },
    );

    return MouseRegion(
      onEnter: (event) => setState(() {
        _isHovered = true;
        _slideThemeLerpT = 1.0;
      }),
      onExit: (event) => setState(() {
        _isHovered = false;
        if (!_isChanging) _slideThemeLerpT = 0;
      }),
      child: tweenAnimation,
    );
  }
}
