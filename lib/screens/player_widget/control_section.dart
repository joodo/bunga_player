import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/player_widget/video_progress_widget.dart';
import 'package:bunga_player/utils.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart' as meedu;

enum ControlUIState {
  main,
  subtitle,
}

enum SubtitleControlUIState {
  position,
  size,
  delay,
}

class ExternalSubtitleSettings {
  final path = ValueNotifier<String?>(null);
  final delay = ValueNotifier<double>(0.0);
  final position = ValueNotifier<double>(0.95);
  final size = ValueNotifier<double>(0.07);
}

SliderThemeData sliderThemeData(context, {double thumbRadius = 10}) {
  return SliderThemeData(
    activeTrackColor: Theme.of(context).colorScheme.secondary,
    thumbColor: Theme.of(context).colorScheme.secondary,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
    valueIndicatorColor: Theme.of(context).colorScheme.secondary,
    trackShape: SliderCustomTrackShape(),
    showValueIndicator: ShowValueIndicator.always,
  );
}

class ControlSection extends StatefulWidget {
  final bool isFullScreen;
  final VoidCallback? onTogglePlayingPressed;
  final ValueSetter<double>? onVolumeSlideChanged;
  final VoidCallback? onToggleFullScreenPressed;

  final ExternalSubtitleSettings externalSubtitleSettings;

  const ControlSection({
    super.key,
    required this.isFullScreen,
    this.onTogglePlayingPressed,
    this.onVolumeSlideChanged,
    this.onToggleFullScreenPressed,
    required this.externalSubtitleSettings,
  });
  @override
  State<ControlSection> createState() => _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  var _uiState = ControlUIState.main;

  // for state main
  bool _showTotalTime = true;

  // for subtitle
  String _currentSubtitle = 'NONE';
  SubtitleControlUIState _subtitleUIState = SubtitleControlUIState.delay;
  final List<DropdownMenuItem<String>> _subtitleDropdowns = [];

  @override
  Widget build(BuildContext context) {
    final controller = VideoController.instance();

    final Widget content;
    switch (_uiState) {
      case ControlUIState.main:
        content = Stack(
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                StreamBuilder(
                  stream: controller.playerStatus.status.stream,
                  builder: (context, snapshot) {
                    bool isPlaying = controller.playerStatus.status.value ==
                        meedu.PlayerStatus.playing;
                    return IconButton(
                      icon: isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                      iconSize: 36,
                      onPressed: widget.onTogglePlayingPressed,
                    );
                  },
                ),
                const SizedBox(width: 8),
                StreamBuilder(
                  stream: controller.volume.stream,
                  builder: (context, snapshot) {
                    double volume = snapshot.data ?? controller.volume.value;
                    return Row(
                      children: [
                        StreamBuilder(
                          stream: controller.mute.stream,
                          builder: (context, snapshot) {
                            bool isMute =
                                snapshot.data ?? controller.mute.value;
                            return IconButton(
                              icon: isMute
                                  ? const Icon(Icons.volume_mute)
                                  : volume > 0.5
                                      ? const Icon(Icons.volume_up)
                                      : const Icon(Icons.volume_down),
                              onPressed: () => controller.setMute(!isMute),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: SliderTheme(
                            data: sliderThemeData(context),
                            child: Slider(
                              value: volume,
                              max: 1.0,
                              label: (volume * 100).toInt().toString(),
                              onChanged: widget.onVolumeSlideChanged,
                              focusNode: FocusNode(canRequestFocus: false),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
                /*
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                logger.d('debug message!!');
              },
            ),
                const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.subtitles),
                  onPressed: () => setState(() {
                    _uiState = ControlUIState.subtitle;
                  }),
                ),
                const SizedBox(width: 8),
            */
                IconButton(
                  icon: widget.isFullScreen
                      ? const Icon(Icons.fullscreen_exit)
                      : const Icon(Icons.fullscreen),
                  onPressed: widget.onToggleFullScreenPressed,
                ),
                const SizedBox(width: 8),
              ],
            ),
            Center(
              child: TextButton(
                child: StreamBuilder(
                  stream: controller.position.stream,
                  builder: (context, snapshot) {
                    final duration = controller.duration.value;
                    final position = snapshot.data ?? controller.position.value;
                    final String positionString = dToHHmmss(position);

                    final String displayString;
                    if (_showTotalTime) {
                      final durationString = dToHHmmss(duration);
                      displayString = '$positionString / $durationString';
                    } else {
                      final remainString = dToHHmmss(duration - position);
                      displayString = '$positionString - $remainString';
                    }
                    return Text(
                      displayString,
                      style: Theme.of(context).textTheme.labelMedium,
                    );
                  },
                ),
                onPressed: () =>
                    setState(() => _showTotalTime = !_showTotalTime),
              ),
            ),
          ],
        );
        break;
      case ControlUIState.subtitle:
        final listenable = {
          SubtitleControlUIState.delay: widget.externalSubtitleSettings.delay,
          SubtitleControlUIState.position:
              widget.externalSubtitleSettings.position,
          SubtitleControlUIState.size: widget.externalSubtitleSettings.size,
        }[_subtitleUIState]!;
        final maxValue = {
          SubtitleControlUIState.delay: 5.0,
          SubtitleControlUIState.position: 1.0,
          SubtitleControlUIState.size: 0.1,
        }[_subtitleUIState]!;
        final minValue = {
          SubtitleControlUIState.delay: -5.0,
          SubtitleControlUIState.position: 0.0,
          SubtitleControlUIState.size: 0.05,
        }[_subtitleUIState]!;

        content = Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() {
                _uiState = ControlUIState.main;
              }),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 240,
              height: 32,
              child: InputDecorator(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 4,
                      top: 4,
                      bottom: 4,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    value: _currentSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    isExpanded: true,
                    isDense: true,
                    onChanged: (String? value) async {
                      if (value == 'OPEN') {
                        const typeGroup = XTypeGroup(
                          label: 'subtitle files',
                          extensions: <String>[
                            'vtt',
                            'srt',
                            'ass',
                            'ttml',
                            'dfxp'
                          ],
                        );
                        // FIXME: acceptedTypeGroups not work
                        //final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                        final file = await openFile();
                        if (file != null) {
                          final p = _subtitleDropdowns
                              .cast<DropdownMenuItem?>()
                              .firstWhere(
                                (element) => element?.value == file.path,
                                orElse: () => null,
                              );
                          if (p == null) {
                            _subtitleDropdowns.add(DropdownMenuItem<String>(
                              value: file.path,
                              child: Text(file.name),
                            ));
                          }
                          setState(() {
                            _currentSubtitle = file.path;
                          });
                        }
                      } else {
                        setState(() {
                          _currentSubtitle = value!;
                        });
                      }

                      widget.externalSubtitleSettings.path.value =
                          _currentSubtitle;
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'NONE',
                        child: Text('无字幕'),
                      ),
                      ..._subtitleDropdowns,
                      const DropdownMenuItem<String>(
                        value: 'OPEN',
                        child: Text('打开……'),
                      ),
                    ],
                    itemHeight: null,
                    selectedItemBuilder: (context) => [
                      const DropdownMenuItem<String>(
                        value: 'NONE',
                        child: Text('无字幕'),
                      ),
                      ..._subtitleDropdowns.map((e) => DropdownMenuItem<String>(
                            value: e.value,
                            child: Text(
                              (e.child as Text).data!,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SegmentedButton<SubtitleControlUIState>(
              segments: const [
                ButtonSegment<SubtitleControlUIState>(
                    value: SubtitleControlUIState.delay,
                    label: Text('延迟'),
                    icon: Icon(Icons.timer)),
                ButtonSegment<SubtitleControlUIState>(
                    value: SubtitleControlUIState.size,
                    label: Text('大小'),
                    icon: Icon(Icons.format_size)),
                ButtonSegment<SubtitleControlUIState>(
                    value: SubtitleControlUIState.position,
                    label: Text('位置'),
                    icon: Icon(Icons.height)),
              ],
              selected: <SubtitleControlUIState>{_subtitleUIState},
              onSelectionChanged: (Set<SubtitleControlUIState> newSelection) {
                setState(() {
                  // By default there is only a single segment that can be
                  // selected at one time, so its value is always the first
                  // item in the selected set.
                  _subtitleUIState = newSelection.first;
                });
              },
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 200,
              child: SliderTheme(
                data: sliderThemeData(context, thumbRadius: 8),
                child: ValueListenableBuilder<double>(
                  valueListenable: listenable,
                  builder: (context, value, child) {
                    return Slider(
                      value: value,
                      divisions: 40,
                      max: maxValue,
                      min: minValue,
                      label: {
                        SubtitleControlUIState.delay: '$value s',
                        SubtitleControlUIState.position: '$value',
                        SubtitleControlUIState.size:
                            (value * 200).toStringAsFixed(2),
                      }[_subtitleUIState]!,
                      onChanged: (value) => listenable.value = value,
                      focusNode: FocusNode(canRequestFocus: false),
                    );
                  },
                ),
              ),
            ),
            /*
            const SizedBox(width: 16),
            SizedBox(
              width: 50,
              height: 32,
              child: ValueListenableBuilder(
                valueListenable: listenable,
                builder: (context, value, child) => TextField(
                  cursorHeight: 16,
                  controller: TextEditingController(),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            */
          ],
        );
        break;
    }

    return content;
  }
}
