import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/mocks/popup_menu.dart' as mock_popup;
import 'package:bunga_player/mocks/slider.dart';
import 'package:bunga_player/singletons/chat.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:bunga_player/singletons/video_player.dart';
import 'package:bunga_player/singletons/voice_call.dart';
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
              valueListenable: VideoPlayer().isPlaying,
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
              valueListenable: VideoPlayer().isMute,
              builder: (context, isMute, child) => IconButton(
                icon: isMute
                    ? const Icon(Icons.volume_mute)
                    : const Icon(Icons.volume_up),
                onPressed: () => VideoPlayer().isMute.value = !isMute,
              ),
            ),
            const SizedBox(width: 8),
            MultiValueListenableBuilder(
              valueListenables: [
                VideoPlayer().volume,
                VideoPlayer().isMute,
              ],
              builder: (context, values, child) => SizedBox(
                width: 100,
                child: MySlider(
                  value: values[1] ? 0.0 : values[0],
                  max: 100.0,
                  label: '${values[0].toInt()}%',
                  onChanged: (value) => VideoPlayer().volume.value = value,
                  focusNode: FocusNode(canRequestFocus: false),
                  useRootOverlay: true,
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

            mock_popup.MyPopupMenuButton(
              icon: const Icon(Icons.more_horiz),
              tooltip: '',
              useRootOverlay: true,
              itemBuilder: (context) => [
                // Tune button
                mock_popup.PopupMenuItem(
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
                mock_popup.PopupMenuItem(
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
                mock_popup.PopupMenuItem(
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
                mock_popup.PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('离开房间'),
                    onTap: () async {
                      Navigator.of(context, rootNavigator: true).pop();

                      final navigator = Navigator.of(context);

                      UINotifiers().isBusy.value = true;
                      await Chat().leaveRoom();
                      await VideoPlayer().stop();

                      navigator.popAndPushNamed('control:welcome');
                      UINotifiers().isBusy.value = false;
                    },
                  ),
                ),
              ],
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
      valueListenable: VoiceCall().callStatus,
      builder: (context, callStatus, child) {
        switch (callStatus) {
          case CallStatus.none:
            return IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                VoiceCall().startAsking();
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
          VideoPlayer().position,
          VideoPlayer().duration,
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
