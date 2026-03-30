import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import '/network/service.dart';
import '/play/play.dart';
import '/services/services.dart';
import '/utils/utils.dart';

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

  final _openFailed = <int>{};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final proxy = MediaPlayer.i.proxyNotifier.value;
    return PanelWidget(
      title: const Text('片源选择'),
      actions: [
        IconButton.filledTonal(
          icon: const Icon(Icons.refresh),
          onPressed: _refresh,
          tooltip: '重新测速',
        ),
      ],
      child: Consumer<PlayPayload>(
        builder: (context, payload, child) => [
          if (proxy != null)
            Text('当前使用代理：$proxy')
                .textColor(Theme.of(context).colorScheme.onSurfaceVariant)
                .padding(horizontal: 22.0, vertical: 8.0),
          payload.sources.videos.indexed
              .map((entry) {
                final (index, source) = entry;

                final info = _sourceInfo[index];

                late final String title;
                if (source.name == null) {
                  title = info?.location ?? '未知';
                } else {
                  final location = info?.location;
                  if (location == null) {
                    title = source.name!;
                  } else {
                    title = '${source.name} ($location)';
                  }
                }
                return RadioListTile(
                  key: ValueKey('Source $index'),
                  title: Text('[${index + 1}] $title'),
                  subtitle: Text(
                    _openFailed.contains(index)
                        ? '打开失败'
                        : info == null
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
                onChanged: (int? value) async {
                  assert(value != null);
                  try {
                    final act =
                        Actions.invoke(
                              context,
                              OpenVideoIntent.switchIndex(value!),
                            )
                            as Future;
                    await act;
                  } catch (_) {
                    if (mounted) {
                      setState(() {
                        _openFailed.add(value!);
                      });
                    }
                  }
                },
              ),
        ].toColumn(crossAxisAlignment: .start),
      ).scrollable(controller: PrimaryScrollController.of(context)),
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
          .sourceInfo(source.url, headers)
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
