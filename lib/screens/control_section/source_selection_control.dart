import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/screens/control_section/dropdown.dart';
import 'package:bunga_player/mocks/dropdown.dart' as mock;
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/network.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SourceSelectionControl extends StatefulWidget {
  const SourceSelectionControl({super.key});

  @override
  State<SourceSelectionControl> createState() => _SourceSelectionControlState();
}

class _SourceSelectionControlState extends State<SourceSelectionControl> {
  final _sourceInfo = <int, (String location, Duration latency)>{};

  @override
  void initState() {
    super.initState();
    final network = getIt<NetworkService>();

    final entry = context.read<PlayVideoEntry>().value!;
    for (final (index, source) in entry.sources.videos.indexed) {
      network.ipInfo(source).then((result) {
        if (mounted) {
          setState(
            () => _sourceInfo[index] = result,
          );
        }
      }).catchError((e) {
        logger.w('[Network] Get ip info failed: $source');
      });
    }
  }

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

        const SizedBox(width: 8),
        Consumer2<PlaySourceIndex, PlayVideoEntry>(
          builder: (context, sourceIndex, videoEntry, child) =>
              videoEntry.value != null
                  ? SizedBox(
                      width: 300,
                      height: 36,
                      child: ControlDropdown(
                        items: [
                          for (int index = 0;
                              index < videoEntry.value!.sources.videos.length;
                              index++)
                            mock.DropdownMenuItem<int>(
                              value: index,
                              child: Text(_getTitle(index)),
                            ),
                        ],
                        value: sourceIndex.value!,
                        onChanged: (index) {
                          Actions.invoke(
                            context,
                            OpenVideoIntent(
                              videoEntry: videoEntry.value!,
                              sourceIndex: index!,
                            ),
                          );
                        },
                      ),
                    )
                  : const Text('载入中'),
        ),
      ],
    );
  }

  String _getTitle(int index) {
    if (!_sourceInfo.containsKey(index)) return '[${index + 1}] 未知';

    final (location, latency) = _sourceInfo[index]!;
    return '[${index + 1}] $location (${latency.inMilliseconds} ms)';
  }
}
