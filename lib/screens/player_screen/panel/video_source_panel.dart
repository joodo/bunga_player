import 'package:bunga_player/network/service.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/int.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
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
  final _sourceInfo = <int, SourceInfo>{};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final proxy = getIt<PlayService>().proxyNotifier.value;
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
        builder: (context, payload, child) => [
          payload.sources.videos.indexed
              .map((entry) => entry.$1)
              .map((index) {
                final info = _sourceInfo[index];
                return RadioListTile(
                  key: ValueKey('Source $index'),
                  title: Text(info?.location ?? '未知'),
                  subtitle: Text(
                    info == null
                        ? '正在测速……'
                        : info.bps < 0
                        ? '测速失败'
                        : '${info.bps.formatBytes} / s',
                  ),
                  value: index,
                );
              })
              .toList()
              .toColumn()
              .radioGroup(
                groupValue: payload.videoSourceIndex,
                onChanged: (int? value) {
                  assert(value != null);
                  Actions.invoke(
                    context,
                    OpenVideoIntent.payload(
                      payload.copyWith(videoSourceIndex: value!),
                      start: getIt<PlayService>().positionNotifier.value,
                    ),
                  );
                },
              ),
          if (proxy != null)
            Text('当前使用代理：$proxy')
                .textStyle(Theme.of(context).textTheme.bodySmall!)
                .padding(horizontal: 8.0, vertical: 20.0),
        ].toColumn(crossAxisAlignment: .start),
      ),
    );
  }

  void _refresh() {
    setState(() => _sourceInfo.clear());

    final network = getIt<NetworkService>();
    final sources = context.read<PlayPayload>().sources;
    final urls = sources.videos;
    final headers = sources.requestHeaders;
    for (final (index, source) in urls.indexed) {
      network
          .sourceInfo(source, headers)
          .then((result) {
            if (mounted) {
              setState(() => _sourceInfo[index] = result);
            }
          })
          .catchError((e) {
            if (mounted) {
              setState(() => _sourceInfo[index] = (location: '未知', bps: -1));
            }
            throw e;
          });
    }
  }
}
