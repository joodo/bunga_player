import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SourceSelectionControl extends StatefulWidget {
  const SourceSelectionControl({super.key});

  @override
  State<SourceSelectionControl> createState() => _SourceSelectionControlState();
}

class _SourceSelectionControlState extends State<SourceSelectionControl> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
        const Spacer(),
        Consumer2<PlaySourceIndex, PlayVideoEntry>(
          builder: (context, sourceIndex, videoEntry, child) =>
              videoEntry.value != null
                  ? SegmentedButton<int>(
                      segments: [
                        for (int index = 0;
                            index < videoEntry.value!.sources.videos.length;
                            index++)
                          ButtonSegment(
                            value: index,
                            label: Text(index.toString()),
                          ),
                      ],
                      selected: {sourceIndex.value!},
                      onSelectionChanged: (values) {
                        final index = values.first;
                        Actions.invoke(
                          context,
                          OpenVideoIntent(
                            videoEntry: videoEntry.value!,
                            sourceIndex: index,
                          ),
                        );
                      },
                    )
                  : const Text('载入中'),
        ),
        const Spacer(),
      ],
    );
  }
}
