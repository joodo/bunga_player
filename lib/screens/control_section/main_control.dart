import 'package:bunga_player/common/fullscreen.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class MainControl extends StatelessWidget {
  final ValueSetter<String> onStateButtonPressed;
  final ValueNotifier<bool> isBusyNotifier;

  const MainControl({
    super.key,
    required this.onStateButtonPressed,
    required this.isBusyNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            // Play button
            ValueListenableBuilder(
              valueListenable: VideoController().isPlaying,
              builder: (context, isPlaying, child) => IconButton(
                icon: isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
                iconSize: 36,
                onPressed: VideoController().togglePlay,
              ),
            ),
            const SizedBox(width: 8),

            // Volume section
            ValueListenableBuilder(
              valueListenable: VideoController().isMute,
              builder: (context, isMute, child) => IconButton(
                icon: isMute
                    ? const Icon(Icons.volume_mute)
                    : const Icon(Icons.volume_up),
                onPressed: () => VideoController().isMute.value = !isMute,
              ),
            ),
            const SizedBox(width: 8),
            MultiValueListenableBuilder(
              valueListenables: [
                VideoController().volume,
                VideoController().isMute,
              ],
              builder: (context, values, child) => SizedBox(
                width: 100,
                child: Slider(
                  value: values[1] ? 0.0 : values[0],
                  max: 100.0,
                  label: '${values[0].toInt()}%',
                  onChanged: (value) => VideoController().volume.value = value,
                  focusNode: FocusNode(canRequestFocus: false),
                ),
              ),
            ),

            const Spacer(),

            // Call Button
            CallButton(
              onPressed: () => onStateButtonPressed('call'),
            ),
            const SizedBox(width: 8),

            // Popmoji Button
            IconButton(
              icon: const Icon(Icons.mood),
              onPressed: () => onStateButtonPressed('popmoji'),
            ),
            const SizedBox(width: 8),

            PopupMenuButton(
              itemBuilder: (context) => [
                // Tune button
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.tune),
                    title: const Text('音视频调整'),
                    onTap: () {
                      Navigator.pop(context);
                      onStateButtonPressed('tune');
                    },
                  ),
                ),
                // Subtitle Button
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.subtitles),
                    title: const Text('字幕调整'),
                    onTap: () {
                      Navigator.pop(context);
                      onStateButtonPressed('subtitle');
                    },
                  ),
                ),
                /*
                // Change Video Button
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.movie_filter),
                    title: const Text('换片'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                */
                // Leave Button
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('离开房间'),
                    onTap: () async {
                      Navigator.pop(context);
                      isBusyNotifier.value = true;
                      await IMController().leaveRoom();
                      await VideoController().stop();
                      onStateButtonPressed('welcome');
                      isBusyNotifier.value = false;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

            // Full screen button
            ValueListenableBuilder(
              valueListenable: FullScreen().notifier,
              builder: (context, isFullScreen, child) => IconButton(
                icon: isFullScreen
                    ? const Icon(Icons.fullscreen_exit)
                    : const Icon(Icons.fullscreen),
                onPressed: FullScreen().toggle,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const Center(child: DurationButton()),
      ],
    );
  }
}

class CallButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const CallButton({
    super.key,
    this.onPressed,
  });

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    upperBound: 0.2,
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.bounceInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: IMController().callStatus,
      builder: (context, callStatus, child) {
        switch (callStatus) {
          case CallStatus.none:
            return IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                IMController().startCallAsking();
                widget.onPressed?.call();
              },
            );
          case CallStatus.callOut:
          case CallStatus.calling:
            return IconButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
              ),
              color: Colors.white70,
              icon: const Icon(Icons.call),
              onPressed: widget.onPressed,
            );
          case CallStatus.callIn:
            return RotationTransition(
              turns: _animation,
              child: IconButton(
                style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.green),
                ),
                color: Colors.white70,
                icon: const Icon(Icons.call),
                onPressed: widget.onPressed,
              ),
            );
        }
      },
    );
  }
}

class DurationButton extends StatefulWidget {
  const DurationButton({super.key});

  @override
  State<DurationButton> createState() => _DurationButtonState();
}

class _DurationButtonState extends State<DurationButton> {
  bool _showTotalTime = true;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: MultiValueListenableBuilder(
        valueListenables: [
          VideoController().position,
          VideoController().duration,
        ],
        builder: (context, values, child) {
          final String positionString = dToHHmmss(values[0]);

          final String displayString;
          if (_showTotalTime) {
            final durationString = dToHHmmss(values[1]);
            displayString = '$positionString / $durationString';
          } else {
            final remainString = dToHHmmss(values[1] - values[0]);
            displayString = '$positionString - $remainString';
          }
          return Text(
            displayString,
            style: Theme.of(context).textTheme.labelMedium,
          );
        },
      ),
      onPressed: () => setState(() => _showTotalTime = !_showTotalTime),
    );
  }
}
