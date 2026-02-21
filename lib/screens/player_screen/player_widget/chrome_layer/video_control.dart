import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/widgets/divider.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/preference_notifier.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/ui/global_business.dart';

import '../../actions.dart';
import '../../business.dart';
import '../../panel/playlist_panel.dart';
import 'menu_builder.dart';

class VideoControl extends StatelessWidget {
  const VideoControl({super.key});

  @override
  Widget build(BuildContext context) {
    final showHud = context.read<ShouldShowHUDNotifier>();

    return LayoutBuilder(
      builder: (context, constraints) => [
        // Play button
        const _PlayButton().padding(horizontal: 8.0),

        // Volume section
        if (kIsDesktop && constraints.maxWidth > 630) const _SliderSection(),

        const ControlDivider(),
        const Spacer(),

        // Duration button
        if (constraints.maxWidth > 420) const _DurationButton(),
        if (constraints.maxWidth > 420) const Spacer(),
        if (constraints.maxWidth > 420) const ControlDivider(),

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
                ShowPanelIntent(builder: (context) => const PlaylistPanel()),
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
      ].toRow(),
    );
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
  late final animation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(controller);

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
      valueListenable: getIt<MediaPlayer>().playStatusNotifier,
      builder: (context, status, child) {
        status.isPlaying ? controller.forward() : controller.reverse();
        return Selector<BusyStateNotifier, bool>(
          selector: (context, notifier) => notifier.isBusy,
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
                    const ToggleIntent(showVisualFeedback: false),
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
    final playService = getIt<MediaPlayer>();
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
          child: Text(
            displayString,
          ).textStyle(Theme.of(context).textTheme.labelMedium!),
        );
      },
    );
  }
}
