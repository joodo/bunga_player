import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/actions/voice_call.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/playing/volume.dart';
import 'package:bunga_player/mocks/popup_menu.dart' as mock;
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/control_section/popmoji_control.dart';
import 'package:bunga_player/utils/duration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainControl extends StatefulWidget {
  const MainControl({super.key});

  @override
  State<MainControl> createState() => _MainControlState();
}

class _MainControlState extends State<MainControl> {
  @override
  void didChangeDependencies() {
    PopmojiControl.cacheSvgs();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final currentChannelData = context.read<CurrentChannelData>().value;
    return Row(
      children: [
        const SizedBox(width: 8),
        // Play button
        Consumer2<PlayStatus, PlayIsBuffering>(
          builder: (context, playStatus, isBuffering, child) =>
              IconButton.filledTonal(
            icon: playStatus.isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
            iconSize: 36,
            onPressed: isBuffering.value
                ? null
                : () => Actions.maybeInvoke(
                      context,
                      const TogglePlayIntent(),
                    ),
          ),
        ),
        const SizedBox(width: 8),

        // Ask position button
        Consumer3<CurrentUser, CurrentChannelId, CurrentChannelWatchers>(
          builder: (context, _, __, ___, child) => IconButton(
            onPressed: Actions.handler(context, AskPositionIntent()),
            icon: child!,
          ),
          child: const Icon(Icons.sync),
        ),

        const VerticalDivider(
          indent: 8,
          endIndent: 8,
        ),

        // Volume section
        Consumer<PlayVolume>(
          builder: (context, volumeData, child) => IconButton(
            icon: volumeData.mute
                ? const Icon(Icons.volume_off)
                : const Icon(Icons.volume_up),
            onPressed: () => Actions.invoke(
              context,
              SetMuteIntent(!volumeData.mute),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Consumer<PlayVolume>(
          builder: (context, volumeData, child) => SizedBox(
            width: 100,
            child: mock.MySlider(
              value: volumeData.mute ? 0.0 : volumeData.volume.toDouble(),
              max: Volume.max.toDouble(),
              label: '${volumeData.volume}%',
              onChanged: (value) => Actions.invoke(
                context,
                SetVolumeIntent(value.toInt()),
              ),
              focusNode: FocusNode(canRequestFocus: false),
              useRootOverlay: true,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const VerticalDivider(
          indent: 8,
          endIndent: 8,
        ),

        // Duration button
        const Spacer(),
        const DurationButton(),
        const Spacer(),
        const VerticalDivider(
          indent: 8,
          endIndent: 8,
        ),

        // Call Button
        const CallButton(),
        const SizedBox(width: 8),

        // Danmaku Button
        IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () => Navigator.of(context).pushNamed('control:danmaku'),
        ),
        const SizedBox(width: 8),

        // Popmoji Button
        IconButton(
          icon: const Icon(Icons.mood),
          onPressed: () => Navigator.of(context).pushNamed('control:popmoji'),
        ),
        const SizedBox(width: 8),

        // FIXME: wait bug fixed then use PopupMenuButton
        // see https://github.com/flutter/flutter/issues/144669
        // TODO: change animation to none
        mock.MyPopupMenuButton(
          icon: const Icon(Icons.more_horiz),
          tooltip: '',
          useRootNavigator: true,
          itemBuilder: (context) => <mock.PopupMenuEntry>[
            if (currentChannelData?.videoType == VideoType.online) ...[
              // Reload button
              mock.PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 12),
                    Text('重新载入'),
                  ],
                ),
                onTap: () {
                  final onlineEntry = context.read<PlayVideoEntry>().value!;
                  final index = context.read<PlaySourceIndex>().value!;
                  Actions.invoke(
                    context,
                    OpenVideoIntent(
                      videoEntry: onlineEntry,
                      sourceIndex: index,
                    ),
                  );
                },
              ),

              // Source button
              mock.PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.rss_feed),
                    SizedBox(width: 12),
                    Text('片源'),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pushNamed('control:source_selection');
                },
              ),

              const mock.PopupMenuDivider(),
            ],

            // Tune button
            mock.PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.tune),
                  SizedBox(width: 12),
                  Text('音视频调整'),
                ],
              ),
              onTap: () {
                Navigator.of(context).pushNamed('control:tune');
              },
            ),
            // Subtitle Button
            mock.PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.subtitles),
                  SizedBox(width: 12),
                  Text('字幕'),
                ],
              ),
              onTap: () {
                Navigator.of(context).pushNamed('control:subtitle');
              },
            ),

            // Change Video Button
            mock.PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.movie_filter),
                  SizedBox(width: 12),
                  Text('换片'),
                ],
              ),
              onTap: () {
                Navigator.of(context).pushNamed('control:open');
              },
            ),

            // Leave Button
            mock.PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 12),
                  Text('离开房间'),
                ],
              ),
              onTap: () async {
                Actions.invoke(context, LeaveChannelIntent());
                Actions.invoke(context, StopPlayIntent());

                Navigator.of(context).popAndPushNamed('control:welcome');
              },
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
    );
  }
}

class CallButton extends StatefulWidget {
  const CallButton({super.key});

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
    return Selector<CurrentCallStatus, CallStatus>(
      selector: (context, currentCallStatus) => currentCallStatus.value,
      builder: (context, callStatus, child) => switch (callStatus) {
        CallStatus.none => IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              Actions.invoke(context, StartCallingRequestIntent());
              _pushNavigate();
            },
          ),
        CallStatus.callOut || CallStatus.talking => IconButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
            ),
            color: Colors.white70,
            icon: const Icon(Icons.call),
            onPressed: _pushNavigate,
          ),
        CallStatus.callIn => RotationTransition(
            turns: _animation,
            child: IconButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
              ),
              color: Colors.white70,
              icon: const Icon(Icons.call),
              onPressed: _pushNavigate,
            ),
          ),
      },
    );
  }

  void _pushNavigate() {
    Navigator.of(context).pushNamed('control:call');
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
    return Consumer2<PlayPosition, PlayDuration>(
      builder: (context, position, duration, child) {
        final displayString = _showTotalTime
            ? '${position.value.hhmmss} / ${duration.value.hhmmss}'
            : '${position.value.hhmmss} - ${(duration.value - position.value).hhmmss}';
        return TextButton(
          child: Text(
            displayString,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onPressed: () => setState(() => _showTotalTime = !_showTotalTime),
        );
      },
    );
  }
}
