import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/singletons/im_controller.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:bunga_player/singletons/video_controller.dart';
import 'package:bunga_player/utils/duration.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class MainControl extends StatelessWidget {
  const MainControl({super.key});

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
                onPressed: () =>
                    Actions.maybeInvoke(context, const TogglePlayIntent()),
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
              onPressed: () => Navigator.of(context).pushNamed('control:call'),
            ),
            const SizedBox(width: 8),

            // Popmoji Button
            IconButton(
              icon: const Icon(Icons.mood),
              onPressed: () =>
                  Navigator.of(context).pushNamed('control:popmoji'),
            ),
            const SizedBox(width: 8),

            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                showMenu(
                  context: context,
                  useRootNavigator: true,
                  position: const RelativeRect.fromLTRB(
                    double.infinity,
                    double.infinity,
                    0,
                    0,
                  ),
                  items: [
                    // Tune button
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.tune),
                        title: const Text('音视频调整'),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context).pushNamed('control:tune');
                        },
                      ),
                    ),
                    // Subtitle Button
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.subtitles),
                        title: const Text('字幕调整'),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context).pushNamed('control:subtitle');
                        },
                      ),
                    ),

                    // Change Video Button
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.movie_filter),
                        title: const Text('换片'),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context).pushNamed('control:open');
                        },
                      ),
                    ),

                    // Leave Button
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('离开房间'),
                        onTap: () async {
                          Navigator.of(context, rootNavigator: true).pop();

                          final navigator = Navigator.of(context);

                          UINotifiers().isBusy.value = true;
                          await IMController().leaveRoom();
                          await VideoController().stop();

                          navigator.popAndPushNamed('control:welcome');
                          UINotifiers().isBusy.value = false;
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 16),

            // Full screen button
            ValueListenableBuilder(
              valueListenable: UINotifiers().isFullScreen,
              builder: (context, isFullScreen, child) => IconButton(
                icon: isFullScreen
                    ? const Icon(Icons.fullscreen_exit)
                    : const Icon(Icons.fullscreen),
                onPressed: () => UINotifiers().isFullScreen.value =
                    !UINotifiers().isFullScreen.value,
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
  AnimationController? _controller;
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller!,
    curve: Curves.bounceInOut,
  );

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      upperBound: 0.2,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
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