import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '/play/models/track.dart';
import '/play/service/service.dart';
import '/utils/utils.dart';

import 'panel.dart';

class AudioTrackPanel extends StatelessWidget implements Panel {
  const AudioTrackPanel({super.key});

  @override
  final type = 'audio_track';

  @override
  Widget build(BuildContext context) {
    final player = MediaPlayer.i;
    return ValueListenableBuilder(
      valueListenable: player.audioTracksNotifier,
      builder: (context, tracks, child) => ValueListenableBuilder(
        valueListenable: player.audioTrackNotifier,
        builder: (context, currentTrack, child) => PanelWidget(
          title: const Text('音轨'),
          child: tracks
              .map(
                (e) => RadioListTile(
                  key: ValueKey(e.id),
                  title: Text(_toTitle(e)),
                  value: e,
                ),
              )
              .toList()
              .toColumn()
              .radioGroup(
                groupValue: currentTrack,
                onChanged: (AudioTrack? value) {
                  if (value != null) {
                    player.audioTrackNotifier.value = value;
                  }
                },
              )
              .scrollable(
                controller: PrimaryScrollController.of(context),
                padding: EdgeInsets.only(bottom: 16.0),
              ),
        ),
      ),
    );
  }

  String _toTitle(AudioTrack track) {
    final lang = track.language == null ? '' : ' (${track.language})';
    final title = track.title == null ? '' : ' ${track.title}';
    return '[${track.id}]$title$lang';
  }
}
