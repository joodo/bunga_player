import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/screens/widgets/divider.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/preference_notifier.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/utils/extensions/comparable.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/ui/providers.dart';

import '../actions.dart';
import '../business.dart';
import '../panel/audio_track_panel.dart';
import '../panel/video_source_panel.dart';
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

              if (constraints.maxWidth > 420) const ControlDivider(),

              // Volume section
              if (constraints.maxWidth > 630) const _SliderSection(),
              if (constraints.maxWidth > 630) const ControlDivider(),

              const Spacer(),

              // Duration button
              if (constraints.maxWidth > 420) const _DurationButton(),
              if (constraints.maxWidth > 420) const Spacer(),
              if (constraints.maxWidth > 420) const ControlDivider(),

              // Danmaku Button
              Selector<DanmakuVisible, bool>(
                selector: (context, visible) => visible.value,
                builder: (context, visible, child) => IconButton(
                  icon: const Icon(Icons.mood),
                  isSelected: visible,
                  onPressed: Actions.handler(
                    context,
                    ToggleDanmakuControlIntent(),
                  ),
                ),
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
    return ValueListenableBuilder(
      valueListenable: getIt<PlayService>().playStatusNotifier,
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
                : () => Actions.maybeInvoke(
                      context,
                      const ToggleIntent(forgetSavedPosition: true),
                    ),
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
    final play = getIt<PlayService>();
    return ValueListenableBuilder(
      valueListenable: play.volumeNotifier,
      builder: (context, volume, child) => [
        IconButton(
          icon: volume.mute
              ? const Icon(Icons.volume_off)
              : const Icon(Icons.volume_up),
          onPressed: () {
            Actions.invoke(
              context,
              UpdateVolumeIntent(volume.copyWith(mute: !volume.mute)),
            );
          },
        ),
        Slider(
          value: volume.mute ? 0.0 : volume.volume.toDouble(),
          max: Volume.max.toDouble(),
          label: '${volume.volume}%',
          onChanged: (value) {
            Actions.invoke(
              context,
              UpdateVolumeIntent(Volume(volume: value.toInt())),
            );
            play.volumeNotifier.value = Volume(volume: value.toInt());
          },
          onChangeEnd: (value) => Actions.invoke(
            context,
            UpdateVolumeIntent.save(),
          ),
          focusNode: FocusNode(canRequestFocus: false),
        ).controlSliderTheme(context).constrained(height: 24).flexible(),
      ].toRow(),
    ).constrained(width: 170);
  }
}

class _DurationButton extends StatefulWidget {
  const _DurationButton();

  @override
  State<_DurationButton> createState() => _DurationButtonState();
}

class _DurationButtonState extends State<_DurationButton> {
  final _showRemainNotifier = createPreferenceNotifier(
    key: 'show_remain_duration',
    initValue: false,
  );

  @override
  void dispose() {
    _showRemainNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playService = getIt<PlayService>();
    return ListenableBuilder(
      listenable: Listenable.merge([
        playService.positionNotifier,
        playService.durationNotifier,
        _showRemainNotifier,
      ]),
      builder: (context, child) {
        final position = playService.positionNotifier.value;
        final duration = playService.durationNotifier.value;
        final displayString = _showRemainNotifier.value
            ? '${position.hhmmss} - ${max(duration - position, Duration.zero).hhmmss}'
            : '${position.hhmmss} / ${duration.hhmmss}';
        return TextButton(
          onPressed: _showRemainNotifier.toggle,
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
                  OpenVideoIntent.record(
                    payload!.record,
                  ),
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
              onPressed: _changeVideo(
                context,
                context.read<IsInChannel>().value,
              ),
              child: const Text('换片'),
            ),

            // Leave Button
            MenuItemButton(
              leadingIcon: const Icon(Icons.logout),
              onPressed: () {
                Actions.invoke(context, const StopPlayingIntent());
                Navigator.of(context).pop();
              },
              child: const Text('离开房间'),
            ),
          ],
        );
      },
    );
  }

  VoidCallback _changeVideo(BuildContext context, bool isCurrentSharing) {
    return () async {
      final result = await showModal<OpenVideoDialogResult>(
        context: context,
        builder: (BuildContext context) => Dialog.fullscreen(
          child: OpenVideoDialog(
            shareToChannel: isCurrentSharing,
            forceShareToChannel: isCurrentSharing,
          ),
        ),
      );
      if (result == null) return;
      if (context.mounted) {
        final act = Actions.invoke(
          context,
          OpenVideoIntent.url(result.url),
        ) as Future<PlayPayload>;

        final payload = await act;
        if (context.mounted && !result.onlyForMe) {
          Actions.invoke(
            context,
            ShareVideoIntent(payload.record),
          );
        }
      }
    };
  }
}
