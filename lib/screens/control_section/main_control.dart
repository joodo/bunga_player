import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/mocks/popup_menu.dart' as mock;
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/ui/ui.dart';
import 'package:bunga_player/providers/states/voice_call.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/utils/duration.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';

class MainControl extends StatelessWidget {
  const MainControl({super.key});

  @override
  Widget build(BuildContext context) {
    final currentChannel = context.read<CurrentChannel>();
    final videoPlayer = context.read<VideoPlayer>();
    final remotePlaying = context.read<RemotePlaying>();

    return Stack(
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            // Play button
            ValueListenableBuilder(
              valueListenable: videoPlayer.isPlaying,
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
              valueListenable: videoPlayer.isMute,
              builder: (context, isMute, child) => IconButton(
                icon: isMute
                    ? const Icon(Icons.volume_mute)
                    : const Icon(Icons.volume_up),
                onPressed: () => videoPlayer.isMute.value = !isMute,
              ),
            ),
            const SizedBox(width: 8),
            MultiValueListenableBuilder(
              valueListenables: [
                videoPlayer.volume,
                videoPlayer.isMute,
              ],
              builder: (context, values, child) => SizedBox(
                width: 100,
                child: mock.MySlider(
                  value: values[1] ? 0.0 : values[0],
                  max: 100.0,
                  label: '${values[0].toInt()}%',
                  onChanged: (value) => videoPlayer.volume.value = value,
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

            mock.MyPopupMenuButton(
              icon: const Icon(Icons.more_horiz),
              tooltip: '',
              useRootOverlay: true,
              itemBuilder: (context) => [
                // Reload button
                if (!(videoPlayer.videoHashNotifier.value
                        ?.startsWith('local') ??
                    true))
                  mock.PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.refresh),
                      title: const Text('重新载入'),
                      onTap: () async {
                        Navigator.of(context, rootNavigator: true).pop();

                        final onlineEntry = VideoEntry.fromChannelData(
                            currentChannel.channelDataNotifier.value!);
                        await remotePlaying.openVideo(onlineEntry);
                      },
                    ),
                  ),

                // Tune button
                mock.PopupMenuItem(
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
                mock.PopupMenuItem(
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
                mock.PopupMenuItem(
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
                mock.PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('离开房间'),
                    onTap: () async {
                      Navigator.of(context, rootNavigator: true).pop();

                      final navigator = Navigator.of(context);

                      currentChannel.leave();
                      await videoPlayer.stop();

                      navigator.popAndPushNamed('control:welcome');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Full screen button
            Consumer<IsFullScreen>(
              builder: (context, isFullScreen, child) => IconButton(
                icon: isFullScreen.value
                    ? const Icon(Icons.fullscreen_exit)
                    : const Icon(Icons.fullscreen),
                onPressed: () => isFullScreen.value = !isFullScreen.value,
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
    return Consumer<VoiceCall>(
      builder: (context, voiceCall, child) => switch (voiceCall.callStatus) {
        CallStatus.none => IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              voiceCall.startAsking();
              widget.onPressed?.call();
            },
          ),
        CallStatus.callOut || CallStatus.calling => IconButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
            ),
            color: Colors.white70,
            icon: const Icon(Icons.call),
            onPressed: widget.onPressed,
          ),
        CallStatus.callIn => RotationTransition(
            turns: _animation,
            child: IconButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
              ),
              color: Colors.white70,
              icon: const Icon(Icons.call),
              onPressed: widget.onPressed,
            ),
          ),
      },
    );
    /*
    return ValueListenableBuilder(
      valueListenable: VoiceCall().callStatusNotifier,
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
    */
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
    final videoPlayer = context.read<VideoPlayer>();
    return TextButton(
      child: MultiValueListenableBuilder(
        valueListenables: [
          videoPlayer.position,
          videoPlayer.duration,
        ],
        builder: (context, values, child) {
          final position = values[0] as Duration;
          final duration = values[1] as Duration;
          final String positionString = position.hhmmss;

          final String displayString;
          if (_showTotalTime) {
            final durationString = duration.hhmmss;
            displayString = '$positionString / $durationString';
          } else {
            final remainString = (duration - position).hhmmss;
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
