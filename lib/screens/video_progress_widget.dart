import 'package:bunga_player/utils.dart';
import 'package:flutter/material.dart';

class VideoProgressWidget extends StatefulWidget {
  final Duration position;
  final Duration duration;

  final ValueSetter<Duration>? onChangeStart;
  final ValueSetter<Duration>? onChanged;
  final ValueSetter<Duration>? onChangeEnd;

  const VideoProgressWidget({
    super.key,
    required this.position,
    required this.duration,
    this.onChangeStart,
    this.onChangeEnd,
    this.onChanged,
  });

  @override
  State<VideoProgressWidget> createState() => _VideoProgressWidgetState();
}

class _VideoProgressWidgetState extends State<VideoProgressWidget> {
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
        child: Slider(
          value: dToS(widget.position),
          max: dToS(widget.duration),
          focusNode: FocusNode(canRequestFocus: false),
          label: dToHHmmss(widget.position),
          onChanged: (double value) {
            widget.onChanged?.call(sToD(value));
          },
          onChangeStart: (value) => setState(() {
            _isChanging = true;
            _slideThemeLerpT = 1.0;
            widget.onChangeStart?.call(sToD(value));
          }),
          onChangeEnd: (value) => setState(() {
            _isChanging = false;
            if (!_isHovered) _slideThemeLerpT = 0;
            widget.onChangeEnd?.call(sToD(value));
          }),
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
