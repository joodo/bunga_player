import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/mocks/dropdown.dart' as mock;
import 'package:bunga_player/services/video_player.dart';
import 'package:bunga_player/screens/control_section/card.dart';
import 'package:bunga_player/screens/control_section/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

class TuneControl extends StatelessWidget {
  const TuneControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
        const SizedBox(width: 8),

        // Contrast button
        ControlCard(
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Text('视频亮度'),
              const SizedBox(width: 12),
              ValueListenableBuilder(
                valueListenable: VideoPlayer().contrast,
                builder: (context, contrast, child) => SizedBox(
                  width: 100,
                  child: mock.MySlider(
                    value: contrast.toDouble(),
                    max: 100,
                    min: -30,
                    label: '$contrast%',
                    onChanged: (value) =>
                        VideoPlayer().contrast.value = value.toInt(),
                    focusNode: FocusNode(canRequestFocus: false),
                    useRootOverlay: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.restart_alt),
                iconSize: 16.0,
                onPressed: VideoPlayer().contrast.reset,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Audio tracks section
        ControlCard(
          child: MultiValueListenableBuilder(
            valueListenables: [
              VideoPlayer().track,
              VideoPlayer().tracks,
            ],
            builder: (context, values, child) {
              var audioTracks = values[1]?.audio as List<AudioTrack>?;

              return Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('音频轨道'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 200,
                    height: 36,
                    child: ControlDropdown(
                      items: audioTracks
                              ?.map((e) => mock.DropdownMenuItem<String>(
                                    value: e.id,
                                    child: Text(() {
                                      if (e.id == 'auto') return '默认';
                                      if (e.id == 'no') return '无声音';

                                      String text = '[${e.id}]';
                                      if (e.title != null) {
                                        text += ' ${e.title}';
                                      }
                                      if (e.language != null) {
                                        text += ' (${e.language})';
                                      }
                                      return text;
                                    }()),
                                  ))
                              .toList() ??
                          [],
                      value: values[0]?.audio.id,
                      onChanged: VideoPlayer().setAudioTrack,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
