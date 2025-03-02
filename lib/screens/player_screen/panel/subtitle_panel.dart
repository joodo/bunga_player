import 'package:bunga_player/play/models/track.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel.dart';

class SubtitlePanel extends StatefulWidget implements Panel {
  const SubtitlePanel({super.key});

  @override
  final type = 'subtitle';

  @override
  State<SubtitlePanel> createState() => _SubtitlePanelState();
}

typedef _TuneArgumentData = ({
  IconData icon,
  String title,
  ValueNotifier<double> notifier,
  double min,
  double max,
  String Function(double value) labelFunc,
});

class _SubtitlePanelState extends State<SubtitlePanel> {
  static final _tuneArguments = <_TuneArgumentData>[
    (
      icon: Icons.timer,
      title: '延迟',
      notifier: getIt<PlayService>().subDelayNotifier,
      min: -20.0,
      max: 20.0,
      labelFunc: (value) => '${value.toStringAsFixed(2)} s',
    ),
    (
      icon: Icons.format_size,
      title: '大小',
      notifier: getIt<PlayService>().subSizeNotifier,
      min: 20.0,
      max: 72.0,
      labelFunc: (value) => value.toInt().toString(),
    ),
    (
      icon: Icons.height,
      title: '高度',
      notifier: getIt<PlayService>().subPosNotifier,
      min: -100.0,
      max: 50.0,
      labelFunc: (value) => '${value.toInt()} %',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final player = getIt<PlayService>();
    final theme = Theme.of(context);

    final tracksSection = ValueListenableBuilder(
      valueListenable: player.subtitleTracksNotifier,
      builder: (context, tracks, child) => ValueListenableBuilder(
        valueListenable: player.subtitleTrackNotifier,
        builder: (context, currentTrack, child) => tracks
            .map((e) => RadioListTile(
                  key: ValueKey(e.id),
                  title: Text(_toTitle(e)),
                  value: e,
                  groupValue: currentTrack,
                  onChanged: (SubtitleTrack? value) {
                    if (value != null) {
                      player.subtitleTrackNotifier.value = value;
                    }
                  },
                ))
            .toList()
            .toColumn(),
      ),
    );

    final body = [
      tracksSection,
      const Text('调整')
          .textStyle(theme.textTheme.labelMedium!)
          .padding(horizontal: 16.0, top: 24.0, bottom: 8.0),
      ..._tuneArguments.map(
        (e) => [
          Icon(e.icon).iconColor(theme.textTheme.bodyMedium!.color!),
          Text(e.title).padding(left: 8.0).constrained(width: 60.0),
          ValueListenableBuilder(
              valueListenable: e.notifier,
              builder: (context, value, child) => Slider(
                    min: e.min,
                    max: e.max,
                    value: value,
                    label: e.labelFunc(value),
                    padding: const EdgeInsets.only(right: 8.0),
                    onChanged: (value) {
                      e.notifier.value = value;
                    },
                  ).controlSliderTheme(context).flexible()),
        ].toRow().padding(horizontal: 16.0),
      ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);

    return PanelWidget(
      title: '字幕',
      actions: [
        IconButton(
          onPressed: _openSubtitle,
          icon: const Icon(Icons.add),
          tooltip: '打开外部字幕',
        ),
      ],
      child: body
          .scrollable(padding: const EdgeInsets.only(bottom: 16.0))
          .flexible(),
    );
  }

  String _toTitle(SubtitleTrack track) {
    final lang = track.language == null ? '' : ' (${track.language})';
    final title = track.title == null ? '' : ' ${track.title}';
    return '[${track.id}]$title$lang';
  }

  void _openSubtitle() async {
    final file = await openFile();
    if (!context.mounted || file == null) return;

    final player = getIt<PlayService>();
    final track = await player.loadSubtitleTrack(file.path);
    player.subtitleTrackNotifier.value = track;
  }
}
