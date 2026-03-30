import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import '/play/play.dart';
import '/play_sync/play_sync.dart';
import '/screens/widgets/divider.dart';
import '/ui/global_business.dart';
import '/utils/utils.dart';

import '../actions.dart';
import '../business.dart';
import '../menu_builder.dart';
import '../panel/playlist_panel.dart';

import 'center_section.dart';

class VideoControl extends StatelessWidget {
  const VideoControl({super.key});

  @override
  Widget build(BuildContext context) {
    final showHud = context.read<ShouldShowHUDNotifier>();

    return LayoutBuilder(
      builder: (context, constraints) =>
          [
            // Play button
            Consumer<IsSyncPlaying?>(
              builder: (context, isSyncPlaying, child) =>
                  ValueListenableBuilder(
                    valueListenable: MediaPlayer.i.playStatusNotifier,
                    builder: (context, playStatus, child) => _PlayButton(
                      isPlaying: isSyncPlaying?.value ?? playStatus.isPlaying,
                    ).padding(horizontal: 8.0),
                  ),
            ),

            // Volume section
            if (kIsDesktop && constraints.maxWidth > 630) const _VolumeSlider(),

            const ControlDivider(),
            const CenterSection().flexible(),
            const ControlDivider(),

            // Danmaku Button
            Consumer2<DanmakuVisible, IsInChannel>(
              builder: (context, visible, inChannel, child) => IconButton(
                icon: const Icon(Icons.mood),
                isSelected: visible.value,
                onPressed: inChannel.value
                    ? Actions.handler(context, ToggleDanmakuControlIntent())
                    : null,
              ),
            ),

            // Dir button
            StyledWidget(
              IconButton(
                icon: const Icon(Icons.queue_music),
                onPressed: () {
                  Actions.invoke(
                    context,
                    ShowPanelIntent(
                      builder: (context) => const PlaylistPanel(),
                    ),
                  );
                },
              ),
            ).padding(right: 8.0),

            // More button
            if (!kIsDesktop)
              MenuBuilder(
                builder: (context, menuChildren, child) => MenuAnchor(
                  builder: (context, controller, child) => IconButton(
                    onPressed: controller.isOpen
                        ? controller.close
                        : controller.open,
                    icon: const Icon(Icons.more_horiz),
                  ),
                  onOpen: () => showHud.lockUp('popup menu'),
                  onClose: () => showHud.unlock('popup menu'),
                  consumeOutsideTap: true,
                  alignmentOffset: Offset(-48.0, 16.0),
                  menuChildren: menuChildren,
                ),
              ).padding(right: 8.0),

            // Full screen button
            if (kIsDesktop)
              Consumer<IsFullScreenNotifier>(
                builder: (context, isFullScreen, child) => IconButton(
                  icon: isFullScreen.value
                      ? const Icon(Icons.fullscreen_exit)
                      : const Icon(Icons.fullscreen),
                  onPressed: () => isFullScreen.value = !isFullScreen.value,
                ),
              ).padding(right: 8.0),
          ].toRow().material(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerLowest.withAlpha(220),
          ),
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({required this.isPlaying});

  final bool isPlaying;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final animation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(controller);

  @override
  void initState() {
    super.initState();
    controller.value = widget.isPlaying ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying == widget.isPlaying) return;
    widget.isPlaying ? controller.forward() : controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<BusyStateNotifier, bool>(
      selector: (context, notifier) => notifier.isBusy,
      builder: (context, isBusy, child) => IconButton.filledTonal(
        icon: AnimatedIcon(icon: AnimatedIcons.play_pause, progress: animation),
        iconSize: 36,
        onPressed: isBusy
            ? null
            : Actions.handler(
                context,
                DirectSetPlaybackIntent(!widget.isPlaying),
              ),
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  const _VolumeSlider();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.read<MediaVolumeNotifier>(),
      builder: (context, volume, child) => [
        IconButton(
          icon: volume.mute
              ? const Icon(Icons.volume_off)
              : const Icon(Icons.volume_up),
          onPressed: () {
            Actions.invoke(
              context,
              UpdateVolumeIntent(
                volume.copyWith(mute: !volume.mute),
                save: true,
              ),
            );
          },
        ),
        Slider(
          value: volume.mute ? 0.0 : volume.level,
          label: '${volume.level.toLevel}%',
          onChangeStart: (value) {
            context.read<ShouldShowHUDNotifier>().lockUp('volume slider');
          },
          onChanged: (value) =>
              Actions.invoke(context, UpdateVolumeIntent(Volume(level: value))),
          onChangeEnd: (value) {
            Actions.invoke(context, FinishUpdateVolumeIntent());
            context.read<ShouldShowHUDNotifier>().unlock('volume slider');
          },
          focusNode: FocusNode(canRequestFocus: false),
        ).controlSliderTheme(context).constrained(height: 24).flexible(),
      ].toRow(),
    ).constrained(width: 170);
  }
}
