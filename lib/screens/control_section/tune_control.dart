import 'package:bunga_player/play/actions.dart';
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/mocks/dropdown.dart' as mock;
import 'package:bunga_player/play/providers.dart';
import 'package:bunga_player/screens/control_section/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/divider.dart';

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

        // Contrast button
        const ControlDivider(),
        const SizedBox(width: 8),
        const Text('视频亮度'),
        const SizedBox(width: 12),

        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.restart_alt),
          iconSize: 16.0,
          onPressed: () => Actions.invoke(
            context,
            const SetContrastIntent(),
          ),
        ),
        const SizedBox(width: 8),

        // Audio tracks section
        const ControlDivider(),
        Consumer2<PlayAudioTracksNotifier, PlayAudioTrackIDNotifier>(
          builder: (context, tracks, currentID, child) {
            return Row(
              children: [
                const SizedBox(width: 16),
                const Text('音频轨道'),
                const SizedBox(width: 8),
                SizedBox(
                  width: 200,
                  height: 36,
                  child: ControlDropdown(
                    items: tracks.value
                        .map(
                          (track) => mock.DropdownMenuItem<String>(
                            value: track.id,
                            child: Text(() {
                              if (track.id == 'auto') return '默认';
                              if (track.id == 'no') return '无声音';
                              return track.toString();
                            }()),
                          ),
                        )
                        .toList(),
                    value: currentID.value,
                    onChanged: (value) {
                      if (value != null) {
                        Actions.invoke(context, SetAudioTrackIntent(value));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],
            );
          },
        ),
        const ControlDivider(),
      ],
    );
  }
}
