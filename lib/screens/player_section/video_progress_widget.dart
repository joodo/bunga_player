import 'package:bunga_player/singletons/im_video_connector.dart';
import 'package:bunga_player/utils/duration.dart';
import 'package:bunga_player/singletons/video_player.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class VideoProgressWidget extends StatefulWidget {
  const VideoProgressWidget({super.key});

  @override
  State<VideoProgressWidget> createState() => _VideoProgressWidgetState();
}

class _VideoProgressWidgetState extends State<VideoProgressWidget> {
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
            return Slider(
              value: dToS(values[0]),
              secondaryTrackValue: dToS(values[2] > values[1]
                  ? values[1]
                  : values[2] < Duration.zero
                      ? Duration.zero
                      : values[2]),
              max: dToS(values[1]),
              focusNode: FocusNode(canRequestFocus: false),
              label: dToHHmmss(values[0]),
              onChangeStart: (value) {
                setState(() {
                  _isChanging = true;
                  _slideThemeLerpT = 1.0;
                });

                _isPlayingBeforeDraggingSlider = VideoPlayer().isPlaying.value;
                VideoPlayer().pause();
                VideoPlayer().seekTo(sToD(value));
              },
              onChanged: (double value) {
                VideoPlayer().seekTo(sToD(value));
              },
              onChangeEnd: (value) async {
                setState(() {
                  _isChanging = false;
                  if (!_isHovered) _slideThemeLerpT = 0;
                });

                await VideoPlayer().seekTo(sToD(value));
                if (_isPlayingBeforeDraggingSlider) VideoPlayer().play();
                IMVideoConnector().sendPlayerStatus();
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
