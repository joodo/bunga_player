import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/utils/duration.dart';
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
    return MouseRegion(
      onEnter: (event) => setState(() {
        _isHovered = true;
        _slideThemeLerpT = 1.0;
      }),
      onExit: (event) => setState(() {
        _isHovered = false;
        if (!_isChanging) _slideThemeLerpT = 0;
      }),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: _slideThemeLerpT),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInCubic,
        builder: (context, value, child) {
          return SliderTheme(
            data: SliderThemeData(
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8 * value),
              trackHeight: 2 + 2 * value,
              trackShape: SliderCustomTrackShape(),
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: child!,
          );
        },
        child: Consumer3<PlayPosition, PlayDuration, PlayBuffer>(
          builder: (context, position, duration, buffer, child) {
            return Slider(
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
          },
        ),
      ),
    );
  }
}

class SliderCustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
