import 'package:bunga_player/controllers/player_controller.dart';
import 'package:bunga_player/utils/duration.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class VideoProgressIndicator extends StatefulWidget {
  const VideoProgressIndicator({super.key});

  @override
  State<VideoProgressIndicator> createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  bool _isHovered = false;
  bool _isChanging = false;
  double _slideThemeLerpT = 0;

  bool _isPlayingBeforeDraggingSlider = false;

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
        child: MultiValueListenableBuilder(
          valueListenables: [
            VideoPlayer().position,
            VideoPlayer().duration,
            VideoPlayer().buffer,
          ],
          builder: (context, values, child) {
            final position = values[0] as Duration;
            final duration = values[1] as Duration;
            final buffer = values[2] as Duration;
            return Slider(
              value: position.inMilliseconds
                  .clamp(0, duration.inMilliseconds)
                  .toDouble(),
              secondaryTrackValue: buffer.inMilliseconds
                  .clamp(0, duration.inMilliseconds)
                  .toDouble(),
              max: duration.inMilliseconds.toDouble(),
              focusNode: FocusNode(canRequestFocus: false),
              label: position.hhmmss,
              onChangeStart: (value) {
                setState(() {
                  _isChanging = true;
                  _slideThemeLerpT = 1.0;
                });

                _isPlayingBeforeDraggingSlider = VideoPlayer().isPlaying.value;
                VideoPlayer().isPlaying.value = false;
                VideoPlayer().position.follow = false;
                VideoPlayer().position.value = value.asMilliseconds;
              },
              onChanged: (double value) {
                VideoPlayer().position.value = value.asMilliseconds;
              },
              onChangeEnd: (value) {
                setState(() {
                  _isChanging = false;
                  if (!_isHovered) _slideThemeLerpT = 0;
                });

                VideoPlayer().position.value = value.asMilliseconds;
                VideoPlayer().position.follow = true;
                if (_isPlayingBeforeDraggingSlider) {
                  VideoPlayer().isPlaying.value = true;
                }
                PlayerController().sendPlayerStatus();
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
