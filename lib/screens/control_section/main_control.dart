import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/actions/voice_call.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/playing/volume.dart';
import 'package:bunga_player/mocks/menu_anchor.dart' as mock;
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/providers/wrapper.dart';
import 'package:bunga_player/screens/control_section/popmoji_control.dart';
import 'package:bunga_player/screens/widgets/video_open_menu_items.dart';
import 'package:bunga_player/utils/comparable.dart';
import 'package:bunga_player/utils/duration.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'channel_required_wrap.dart';

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
    final body = Row(
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
        Consumer3<CurrentUser, CurrentChannel, CurrentChannelWatchers>(
          builder: (context, _, __, ___, child) => IconButton(
            onPressed: Actions.handler(context, AskPositionIntent()),
            icon: child!,
          ),
          child: const Icon(Icons.sync),
        ),

        const VerticalDivider(indent: 8, endIndent: 8),

        // Volume section
        const _SliderSection(),
        const VerticalDivider(indent: 8, endIndent: 8),

        // Duration button
        const Spacer(),
        const _DurationButton(),
        const Spacer(),

        // Call Button
        const VerticalDivider(indent: 8, endIndent: 8),
        const SizedBox(width: 8),
        const _CallButton(),
        const SizedBox(width: 8),

        // Danmaku Button
        ChannelRequiredWrap(
          builder: (context, action, child) => IconButton(
            icon: const Icon(Icons.chat),
            onPressed: action,
          ),
          action: () => Navigator.of(context).pushNamed('control:danmaku'),
        ),
        const SizedBox(width: 8),

        // Popmoji Button
        ChannelRequiredWrap(
          builder: (context, action, child) => IconButton(
            icon: const Icon(Icons.mood),
            onPressed: action,
          ),
          action: () => Navigator.of(context).pushNamed('control:popmoji'),
        ),
        const SizedBox(width: 8),

        mock.MyMenuAnchor(
          builder: (context, controller, child) => IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.more_horiz),
          ),
          style: Theme.of(context).menuTheme.style,
          alignmentOffset: const Offset(-50, 8),
          rootOverlay: true,
          consumeOutsideTap: true,
          menuChildren: [
            if (context.read<PlayVideoEntry>().value is! LocalVideoEntry) ...[
              // Reload button
              mock.MenuItemButton(
                leadingIcon: const Icon(Icons.refresh),
                child: const Text('重新载入'),
                onPressed: () {
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
              mock.MenuItemButton(
                leadingIcon: const Icon(Icons.rss_feed),
                child: const Text('片源'),
                onPressed: () {
                  Navigator.of(context).pushNamed('control:source_selection');
                },
              ),

              const Divider(),
            ],

            // Tune button
            mock.MenuItemButton(
              leadingIcon: const Icon(Icons.tune),
              child: const Text('音视频调整    '),
              onPressed: () {
                Navigator.of(context).pushNamed('control:tune');
              },
            ),

            // Subtitle Button
            mock.MenuItemButton(
              child: const Row(
                children: [
                  Icon(Icons.subtitles),
                  SizedBox(width: 12),
                  Text('字幕'),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('control:subtitle');
              },
            ),

            // Change Video Button
            mock.SubmenuButton(
              leadingIcon: const Icon(Icons.movie_filter),
              menuChildren: VideoOpenMenuItemsCreator(
                context,
                onVideoOpened: _onVideoOpened,
              ).create(),
              child: const Text('换片'),
            ),

            // Leave Button
            mock.MenuItemButton(
              leadingIcon: const Icon(Icons.logout),
              onPressed: _leaveChannel,
              child: const Text('离开房间'),
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

    final danmakuShortcut =
        context.read<SettingShortcutMapping>().value[ShortcutKey.danmaku];
    return ChannelRequiredWrap(
      builder: (context, action, child) => CallbackShortcuts(
        bindings: {
          if (action != null && danmakuShortcut != null) danmakuShortcut: action
        },
        child: Focus(autofocus: true, child: child!),
      ),
      action: () => Navigator.of(context).pushNamed('control:danmaku'),
      child: body,
    );
  }

  void _leaveChannel() async {
    Actions.invoke(context, StopPlayIntent());
    context.read<CurrentChannelJoinPayload>().value = null;
    Navigator.of(context).popAndPushNamed('control:welcome');
  }

  void _onVideoOpened(VideoEntry entry) {
    if (!mounted) throw Exception('Context unmounted');

    final currentUser = context.read<CurrentUser>().value;
    if (!context.isVideoSameWithChannel && currentUser != null) {
      Actions.maybeInvoke(
        context,
        UpdateChannelDataIntent(
          ChannelData.fromShare(
            currentUser,
            entry,
          ),
        ),
      );
    }
  }
}

class _SliderSection extends StatelessWidget {
  const _SliderSection();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: PageView(
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        children: [
          Row(
            children: [
              Consumer<PlayVolume>(
                builder: (context, volumeData, child) => IconButton(
                  icon: volumeData.value.mute
                      ? const Icon(Icons.volume_off)
                      : const Icon(Icons.volume_up),
                  onPressed: () => Actions.invoke(
                    context,
                    SetMuteIntent(!volumeData.value.mute),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Consumer<PlayVolume>(
                  builder: (context, volumeData, child) => mock.MySlider(
                    value: volumeData.value.mute
                        ? 0.0
                        : volumeData.value.volume.toDouble(),
                    max: Volume.max.toDouble(),
                    label: '${volumeData.value.volume}%',
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
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.speed),
                onPressed: context.read<PlayRate>().reset,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Consumer<PlayRate>(
                  builder: (context, playRate, child) => mock.MySlider(
                    min: 0.25,
                    max: 1.75,
                    divisions: 6,
                    value: playRate.value,
                    label: ' ×${playRate.value} ',
                    onChanged: (value) => playRate.value = value,
                    focusNode: FocusNode(canRequestFocus: false),
                    useRootOverlay: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatefulWidget {
  const _CallButton();

  @override
  State<_CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<_CallButton>
    with TickerProviderStateMixin {
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
        CallStatus.none => Selector<CurrentChannel, bool>(
            selector: (conext, channelId) => channelId.value != null,
            builder: (context, loaded, child) => IconButton(
              icon: const Icon(Icons.call),
              onPressed: loaded
                  ? () {
                      Actions.invoke(context, StartCallingRequestIntent());
                      _pushNavigate();
                    }
                  : null,
            ),
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

class _DurationButton extends StatelessWidget {
  const _DurationButton();
  @override
  Widget build(BuildContext context) {
    return Consumer3<PlayPosition, PlayDuration, SettingShowRemainDuration>(
      builder: (context, position, duration, showRemainDuration, child) {
        final displayString = showRemainDuration.value
            ? '${position.value.hhmmss} - ${max(duration.value - position.value, Duration.zero).hhmmss}'
            : '${position.value.hhmmss} / ${duration.value.hhmmss}';
        return TextButton(
          onPressed: showRemainDuration.toggle,
          child: Text(
            displayString,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        );
      },
    );
  }
}
