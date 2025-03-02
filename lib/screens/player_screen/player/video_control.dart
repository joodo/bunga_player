import 'package:animations/animations.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/play_sync/providers.dart';
import 'package:bunga_player/play/actions.dart' as player_actions;
import 'package:bunga_player/play_sync/actions.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/screens/player_screen/actions.dart';
import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:bunga_player/screens/player_screen/panel/video_source_panel.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/actions.dart';
import 'package:bunga_player/chat/models/channel_data.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/play/models/video_entries/video_entry.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/play/providers.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/screens/widgets/video_open_menu_items.dart';
import 'package:bunga_player/utils/extensions/comparable.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/voice_call/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../widgets/divider.dart';
import '../../control_section/channel_required_wrap.dart';
import '../panel/audio_track_panel.dart';
import '../panel/playlist_panel.dart';
import '../panel/subtitle_panel.dart';
import '../panel/video_eq_panel.dart';

class VideoControl extends StatelessWidget {
  const VideoControl({super.key});

  @override
  Widget build(BuildContext context) {
    final showHud = context.read<ShouldShowHUD>();

    return LayoutBuilder(
        builder: (context, constraints) => [
              // Play button
              const _PlayButton().padding(left: 8.0),

              // Ask position button
              /* TODO: onprogress
          Tooltip(
            message: '拉取远程进度',
            child: Consumer3<ChatUser, ChatChannel, ChatChannelWatchers>(
              builder: (context, _, __, ___, child) => IconButton(
                onPressed: Actions.handler(context, const AskPositionIntent()),
                icon: child!,
              ),
              child: const Icon(Icons.sync),
            ),
          ),
          */

              const ControlDivider(),

              // Volume section
              if (constraints.maxWidth > 630) const _SliderSection(),
              if (constraints.maxWidth > 630) const ControlDivider(),

              const Spacer(),

              // Duration button
              const _DurationButton(),

              const Spacer(),

              const ControlDivider(),
              /* TODO: onprogress
          // Call Button
          const SizedBox(width: 8),
          _CallButton(
              onPressed: () => Navigator.of(context).pushNamed('control:call')),
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
        
          const SizedBox(width: 8),
        */
              // Popmoji Button
              IconButton(
                icon: const Icon(Icons.mood),
                onPressed: () {},
              ),

              // Dir button
              StyledWidget(IconButton(
                icon: const Icon(Icons.queue_music),
                onPressed: () {
                  Actions.invoke(
                    context,
                    ShowPanelIntent(
                      builder: (context) => const PlaylistPanel(),
                    ),
                  );
                },
              )).padding(right: 8.0),

              // More button
              _MoreActionsButton(
                onMenuOpen: () => showHud.lockUp('popup menu'),
                onMenuClose: () => showHud.unlock('popup menu'),
              ).padding(right: 8.0),

              // Full screen button
              if (kIsDesktop)
                Consumer<IsFullScreen>(
                  builder: (context, isFullScreen, child) => IconButton(
                    icon: isFullScreen.value
                        ? const Icon(Icons.fullscreen_exit)
                        : const Icon(Icons.fullscreen),
                    onPressed: () => isFullScreen.value = !isFullScreen.value,
                  ),
                ).padding(right: 8.0),
            ].toRow());
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton();

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final animation =
      Tween<double>(begin: 0.0, end: 1.0).animate(controller);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayStatus>(
      builder: (context, status, child) {
        status.isPlaying ? controller.forward() : controller.reverse();
        return Selector<BusyCount, bool>(
          selector: (context, count) => count.isBusy,
          builder: (context, isBusy, child) => IconButton.filledTonal(
            icon: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: animation,
            ),
            iconSize: 36,
            onPressed: isBusy
                ? null
                : () => Actions.maybeInvoke(context, ToggleIntent()),
          ),
        );
      },
    );
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
          [
            Consumer<PlayVolume>(
              builder: (context, volumeData, child) => IconButton(
                icon: volumeData.value.mute
                    ? const Icon(Icons.volume_off)
                    : const Icon(Icons.volume_up),
                onPressed: () => Actions.invoke(
                  context,
                  player_actions.SetMuteIntent(!volumeData.value.mute),
                ),
              ),
            ),
            Consumer<PlayVolume>(
                    builder: (context, volumeData, child) => Slider(
                          value: volumeData.value.mute
                              ? 0.0
                              : volumeData.value.volume.toDouble(),
                          max: Volume.max.toDouble(),
                          label: '${volumeData.value.volume}%',
                          onChanged: (value) => Actions.invoke(
                            context,
                            player_actions.SetVolumeIntent(value.toInt()),
                          ),
                          onChangeEnd: (value) =>
                              context.read<PlayVolume>().save(value.round()),
                          focusNode: FocusNode(canRequestFocus: false),
                        ).controlSliderTheme(context).constrained(height: 24))
                .flexible(),
          ].toRow(),
          [
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
          ].toRow(),
        ],
      ),
    );
  }
}

class _CallButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _CallButton({required this.onPressed});

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
    return Selector<VoiceCallStatus, VoiceCallStatusType>(
      selector: (context, currentCallStatus) => currentCallStatus.value,
      builder: (context, callStatus, child) => switch (callStatus) {
        VoiceCallStatusType.none => Selector<ChatChannel, bool>(
            selector: (conext, channelId) => channelId.value != null,
            builder: (context, loaded, child) => IconButton(
              icon: const Icon(Icons.call),
              onPressed: loaded
                  ? () {
                      Actions.invoke(context, StartCallingRequestIntent());
                      widget.onPressed();
                    }
                  : null,
            ),
          ),
        VoiceCallStatusType.callOut ||
        VoiceCallStatusType.talking =>
          IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(Colors.green),
            ),
            color: Colors.white70,
            icon: const Icon(Icons.call),
            onPressed: widget.onPressed,
          ),
        VoiceCallStatusType.callIn => RotationTransition(
            turns: _animation,
            child: IconButton(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.green),
              ),
              color: Colors.white70,
              icon: const Icon(Icons.call),
              onPressed: widget.onPressed,
            ),
          ),
      },
    );
  }
}

class _DurationButton extends StatelessWidget {
  const _DurationButton();
  @override
  Widget build(BuildContext context) {
    return Consumer3<PlayPosition, PlayDuration, ShowRemainDuration>(
      builder: (context, position, duration, showRemainDuration, child) {
        final displayString = showRemainDuration.value
            ? '${position.value.hhmmss} - ${max(duration.value - position.value, Duration.zero).hhmmss}'
            : '${position.value.hhmmss} / ${duration.value.hhmmss}';
        return TextButton(
          onPressed: showRemainDuration.toggle,
          child: Text(displayString).textStyle(
            Theme.of(context).textTheme.labelMedium!,
          ),
        );
      },
    );
  }
}

class _MoreActionsButton extends StatelessWidget {
  final VoidCallback? onMenuOpen, onMenuClose;
  const _MoreActionsButton({this.onMenuOpen, this.onMenuClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayPayload?>(
      builder: (context, payload, child) {
        final isLocalVideo = {'local', null}.contains(payload?.record.source);
        return MenuAnchor(
          builder: (context, controller, child) => IconButton(
            onPressed: controller.isOpen ? controller.close : controller.open,
            icon: const Icon(Icons.more_horiz),
          ),
          onOpen: onMenuOpen,
          onClose: onMenuClose,
          consumeOutsideTap: true,
          menuChildren: [
            if (!isLocalVideo) ...[
              // Reload button
              MenuItemButton(
                leadingIcon: const Icon(Icons.refresh),
                onPressed: Actions.handler(
                  context,
                  OpenVideoIntent.record(payload!.record),
                ),
                child: const Text('重新载入    '),
              ),

              // Source button
              MenuItemButton(
                leadingIcon: const Icon(Icons.rss_feed),
                onPressed: Actions.handler(
                  context,
                  ShowPanelIntent(
                    builder: (context) => const VideoSourcePanel(),
                  ),
                ),
                child: Text('片源 (${payload.sources.videos.length})'),
              ),

              const Divider(),
            ],

            SubmenuButton(
              leadingIcon: const Icon(Icons.tune),
              menuChildren: [
                // Video button
                MenuItemButton(
                  leadingIcon: const Icon(Icons.image),
                  onPressed: Actions.handler(
                    context,
                    ShowPanelIntent(
                      builder: (context) => const VideoEqPanel(),
                    ),
                  ),
                  child: const Text('画面   '),
                ),
                // Audio button
                MenuItemButton(
                  leadingIcon: const Icon(Icons.music_note),
                  onPressed: Actions.handler(
                    context,
                    ShowPanelIntent(
                      builder: (context) => const AudioTrackPanel(),
                    ),
                  ),
                  child: const Text('音轨'),
                ),
                // Subtitle Button
                MenuItemButton(
                  leadingIcon: const Icon(Icons.subtitles),
                  onPressed: Actions.handler(
                    context,
                    ShowPanelIntent(
                      builder: (context) => const SubtitlePanel(),
                    ),
                  ),
                  child: const Text('字幕'),
                ),
              ],
              child: const Text('调整'),
            ),

            // Change Video Button
            MenuItemButton(
              leadingIcon: const Icon(Icons.movie_filter),
              onPressed: _changeVideo(context),
              child: const Text('换片'),
            ),

            // Leave Button
            MenuItemButton(
              leadingIcon: const Icon(Icons.logout),
              onPressed: () => _leaveChannel(context),
              child: const Text('离开房间'),
            ),
          ],
        );
      },
    );
  }

  VoidCallback _changeVideo(BuildContext context) {
    return () async {
      final result = await showGeneralDialog<OpenVideoDialogResult>(
        context: context,
        pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            const Dialog.fullscreen(
          child: OpenVideoDialog(forceShareToChannel: true),
        ),
        transitionBuilder: (context, animation, secondaryAnimation, child) =>
            FadeScaleTransition(
          animation: animation,
          child: child,
        ),
      );
      if (result == null) return;
      if (context.mounted) {
        Actions.invoke(context, OpenVideoIntent.url(result.url));
      }
    };
  }

  void _leaveChannel(BuildContext context) async {
    if (!kIsDesktop) {
      context.read<PlayVideoSessions>().save();
    }

    Actions.invoke(context, const player_actions.StopPlayIntent());
    //Actions.maybeInvoke(context, const LeaveChannelIntent());
    Navigator.of(context).pop();
  }

  void _onVideoOpened(BuildContext context, VideoEntry entry) {
    final currentUser = context.read<ChatUser>().value;
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
