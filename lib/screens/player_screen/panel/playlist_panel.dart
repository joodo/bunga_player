import 'dart:math';

import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/screens/player_screen/actions.dart';
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
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DirInfo?>(
      builder: (context, dirInfo, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrent();
        });
        return PanelWidget(
          title: dirInfo?.name ?? '',
          actions: [
            Consumer<PlayPayload?>(
              builder: (context, value, child) => IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '刷新目录',
                onPressed: Actions.handler(context, RefreshDirIntent()),
              ),
            ),
          ],
          child: dirInfo == null
              ? const Text('没有其他视频').center()
              : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 24.0),
                      itemBuilder: (context, index) {
                        final epInfo = dirInfo.info[index];
                        final current = dirInfo.current == index;
                        return ListTile(
                          key: ValueKey('ep$index'),
                          selected: current,
                          title: Text(
                            epInfo.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: current ? const Text('当前播放') : null,
                          trailing: epInfo.thumb != null
                              ? Image.network(
                                  epInfo.thumb!,
                                  key: ValueKey(epInfo.thumb!),
                                ).clipRRect(all: 8.0)
                              : null,
                          onTap: current
                              ? null
                              : () async {
                                  final read = context.read;

                                  final shouldShare =
                                      read<List<User>?>() != null;

                                  final act = Actions.invoke(
                                    context,
                                    OpenVideoIntent.url(epInfo.url),
                                  ) as Future<PlayPayload>;

                                  final payload = await act;
                                  if (context.mounted && shouldShare) {
                                    Actions.invoke(
                                      context,
                                      ShareVideoIntent(payload.record),
                                    );
                                  }
                                },
                        ).animatedSize(
                          duration: const Duration(milliseconds: 200),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(indent: 16.0),
                      itemCount: dirInfo.info.length)
                  .expanded(),
        );
      },
    );
  }

  void _scrollToCurrent() {
    final currentIndex = context.read<DirInfo?>()?.current;
    if (currentIndex == null) return;

    final offset = currentIndex * (48.0 + 16.0);
    final maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      min(offset, maxScroll),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }
}
