import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/screens/widgets/slider_dense_track_shape.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({super.key});

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  bool _isHovered = false;
  bool _isDragging = false;

  // Player
  final _positionNotifier = getIt<PlayService>().positionNotifier;
  double _currentPosition = 0;
  void _followPlayerPosition() {
    setState(() {
      _currentPosition = _positionNotifier.value.inMilliseconds.toDouble();
    });
  }

  // Drag business
  bool _isPlayingBeforeDraggingSlider = false;

  @override
  void initState() {
    super.initState();

    // always show max size when not desktop
    if (!kIsDesktop) _isHovered = true;

    _positionNotifier.addListener(_followPlayerPosition);
  }

  @override
  void dispose() {
    _positionNotifier.removeListener(_followPlayerPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = getIt<PlayService>();
    final tweenAnimation = ListenableBuilder(
      listenable: Listenable.merge([
        player.durationNotifier,
        player.bufferNotifier,
      ]),
      builder: (context, child) {
        final showHUDNotifier = context.read<ShouldShowHUDNotifier>();

        final duration = player.durationNotifier.value;
        final position = Duration(milliseconds: _currentPosition.toInt());
        final buffer = player.bufferNotifier.value;

        final slider = Slider(
          value: position.inMilliseconds
              .clamp(0, duration.inMilliseconds)
              .toDouble(),
          secondaryTrackValue: buffer.inMilliseconds
              .clamp(0, duration.inMilliseconds)
              .toDouble(),
          max: duration.inMilliseconds.toDouble(),
          focusNode: FocusNode(
            canRequestFocus: false,
          ), // avoid control by left / right key
          label: position.hhmmss,
          onChangeStart: (value) {
            _positionNotifier.removeListener(_followPlayerPosition);

            Actions.maybeInvoke(context, SeekStartIntent());

            _isPlayingBeforeDraggingSlider =
                player.playStatusNotifier.value.isPlaying;
            player.pause();

            final pos = Duration(milliseconds: value.toInt());
            player.seek(pos);

            setState(() {
              _currentPosition = value;
              _isDragging = true;
            });

            showHUDNotifier.lockUp('drag');
          },
          onChanged: duration.inMilliseconds == 0
              ? null
              : (double value) {
                  final pos = Duration(milliseconds: value.toInt());
                  player.seek(pos);

                  setState(() {
                    _currentPosition = value;
                  });
                },
          onChangeEnd: (value) {
            if (_isPlayingBeforeDraggingSlider) player.play();

            final pos = Duration(milliseconds: value.toInt());
            player.seek(pos).then((_) {
              if (!context.mounted) return;
              Actions.maybeInvoke(context, SeekEndIntent());
            });

            _positionNotifier.addListener(_followPlayerPosition);

            setState(() {
              _currentPosition = value;
              _isDragging = false;
            });

            showHUDNotifier.unlock('drag');
          },
        );

        return TweenAnimationBuilder(
          tween: Tween<double>(end: _isHovered || _isDragging ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInCubic,
          builder: (context, value, child) {
            return Selector<BusyStateNotifier, bool>(
              selector: (context, state) => state.isBusy,
              builder: (context, isBusy, _) {
                final trackColor = isBusy ? Colors.transparent : null;
                return SliderTheme(
                  data: SliderThemeData(
                    thumbColor: Theme.of(context).colorScheme.primary,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: isBusy ? 8 : 8 * value,
                    ),
                    trackHeight: 2 + 2 * value,
                    trackShape: SliderDenseTrackShape(),
                    showValueIndicator: ShowValueIndicator.onDrag,
                    // for buffer
                    activeTrackColor: trackColor,
                    secondaryActiveTrackColor: trackColor,
                    inactiveTrackColor: trackColor,
                  ),
                  child: [
                    if (isBusy) const LinearProgressIndicator(minHeight: 4),
                    child!,
                  ].toStack(alignment: .center),
                );
              },
            );
          },
          child: slider,
        );
      },
    );

    if (!kIsDesktop) {
      return tweenAnimation;
    } else {
      return MouseRegion(
        onEnter: (event) => setState(() {
          _isHovered = true;
        }),
        onExit: (event) => setState(() {
          _isHovered = false;
        }),
        child: tweenAnimation,
      );
    }
  }
}
