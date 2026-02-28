import 'dart:math';

import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel.dart';

class PlaylistPanel extends StatefulWidget implements Panel {
  const PlaylistPanel({super.key});

  @override
  final type = 'playlist';

  @override
  State<PlaylistPanel> createState() => _PlaylistPanelState();
}

class _PlaylistPanelState extends State<PlaylistPanel> {
  @override
  void initState() {
    super.initState();

    runAfterBuild(_scrollToCurrent);
  }

  @override
  Widget build(BuildContext context) {
    final dirInfo = context.read<DirInfo?>();
    return PanelWidget(
      title: Text(dirInfo?.name ?? ''),
      actions: [
        Consumer<PlayPayload?>(
          builder: (context, value, child) => IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新目录',
            onPressed: () async {
              final busyNotifier = context.read<PanelBusyNotifier>();

              try {
                busyNotifier.value = true;
                final act =
                    Actions.invoke(context, RefreshDirIntent()) as Future;
                await act;
                setState(() {});
              } finally {
                busyNotifier.value = false;
              }
            },
          ),
        ),
      ],
      child: dirInfo == null
          ? SliverFillRemaining(
              hasScrollBody: false,
              child: const Text('没有其他视频').center(),
            )
          : ListView.separated(
              controller: PrimaryScrollController.of(context),
              itemBuilder: (context, index) {
                final epInfo = dirInfo.info[index];
                // Move consumer inside ListTile to avoid rebuild all list
                return Selector<DirInfo, bool>(
                  selector: (context, dirInfo) => dirInfo.current == index,
                  builder: (context, current, child) => ListTile(
                    selected: current,
                    title: Text(epInfo.name, maxLines: 2, overflow: .ellipsis),
                    subtitle: current ? const Text('当前播放') : null,
                    trailing: epInfo.thumb != null
                        ? Image.network(epInfo.thumb!).clipRRect(all: 8.0)
                        : null,
                    onTap: current
                        ? null
                        : () async {
                            if (context.read<IsInChannel>().value) {
                              Actions.invoke(
                                context,
                                ShareVideoIntent.url(epInfo.url),
                              );
                            } else {
                              Actions.invoke(
                                context,
                                OpenVideoIntent.url(epInfo.url),
                              );
                            }
                          },
                  ).animatedSize(duration: const Duration(milliseconds: 200)),
                );
              },
              separatorBuilder: (context, index) => const Divider(indent: 16.0),
              itemCount: dirInfo.info.length,
            ),
    );
  }

  void _scrollToCurrent() {
    final currentIndex = context.read<DirInfo?>()?.current;
    if (currentIndex == null) return;

    final offset = currentIndex * (48.0 + 16.0);

    final controller = PrimaryScrollController.of(context);
    final maxScroll = controller.position.maxScrollExtent;
    controller.jumpTo(min(offset, maxScroll));
  }
}
