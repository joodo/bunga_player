import 'package:bunga_player/network/service.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/screens/player_screen/actions.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel.dart';

class VideoSourcePanel extends StatefulWidget implements Panel {
  const VideoSourcePanel({super.key});

  @override
  final type = 'video_source';

  @override
  State<VideoSourcePanel> createState() => _VideoSourcePanelState();
}

class _VideoSourcePanelState extends State<VideoSourcePanel> {
  final _sourceInfo = <int, IpInfo>{};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PanelWidget(
      title: '片源选择',
      actions: [
        IconButton.filledTonal(
          icon: const Icon(Icons.refresh),
          onPressed: _refresh,
          tooltip: '重新测速',
        ),
      ],
      child: Consumer<PlayPayload>(
        builder: (context, payload, child) => payload.sources.videos.indexed
            .map((entry) => entry.$1)
            .map((index) => RadioListTile(
                  key: ValueKey('Source $index'),
                  title: Text(_sourceInfo[index]?.location ?? '未知'),
                  subtitle:
                      Text('${_sourceInfo[index]?.latency.inMilliseconds} ms'),
                  value: index,
                  groupValue: payload.videoSourceIndex,
                  onChanged: (int? value) {
                    assert(value != null);
                    Actions.invoke(
                      context,
                      OpenVideoIntent.payload(
                        payload.copyWith(videoSourceIndex: value!),
                      ),
                    );
                  },
                ))
            .toList()
            .toColumn(),
      ),
    );
  }

  void _refresh() {
    final network = getIt<NetworkService>();

    final sources = context.read<PlayPayload>().sources.videos;
    for (final (index, source) in sources.indexed) {
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
}
