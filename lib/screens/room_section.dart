import 'dart:async';

import 'package:animations/animations.dart';
import 'package:bunga_player/play_sync/models.dart';
import 'package:bunga_player/play_sync/providers.dart';
import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/chat/models/channel_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/player/models/video_entries/video_entry.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
import 'package:bunga_player/screens/widgets/loading_text.dart';
import 'package:bunga_player/screens/wrappers/providers.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoomSection extends StatefulWidget {
  const RoomSection({super.key});

  @override
  State<RoomSection> createState() => _RoomSectionState();
}

class _RoomSectionState extends State<RoomSection> {
  @override
  Widget build(BuildContext context) {
    return Selector<PlayVideoEntry, VideoEntry?>(
      selector: (context, notifier) => notifier.value,
      builder: (context, videoEntry, child) => videoEntry == null
          ? const SizedBox.shrink()
          : Row(
              children: [
                // Watcher list
                Consumer<ChatChannelJoinPayload>(
                  builder: (context, payload, child) => payload.value == null
                      ? TextButton(
                          child: const Text('创建房间'),
                          onPressed: () => payload.value =
                              ChannelJoinByEntryPayload(videoEntry),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Consumer<ChatChannelWatchers>(
                            builder: (context, watchers, child) {
                              return watchers.value.isEmpty
                                  ? const LoadingText('正在进入房间')
                                  : _getUsersWidget(watchers.value);
                            },
                          ),
                        ),
                ),
                const Spacer(),

                // Unsync hint
                ValueListenableConsumer<ChatChannelData, ChannelData?>(
                  builder: (context, channelData, child) {
                    if (channelData == null || context.isVideoSameWithChannel) {
                      return const SizedBox.shrink();
                    }
                    return _VideoUnsyncNotification(
                      otherUserName: channelData.sharer.name,
                      otherVideoTitle: channelData.name,
                      onAction: () => _onOpenVideoPressed(channelData),
                    );
                  },
                ),
              ],
            ),
    );
  }

  void _onOpenVideoPressed(ChannelData channelData) {
    channelData.videoType == VideoType.local
        ? _openLocalVideo()
        : Actions.invoke(
            context,
            OpenVideoIntent(
              videoEntry: VideoEntry.fromChannelData(channelData),
            ),
          );
  }

  void _openLocalVideo() async {
    final entry = await LocalVideoEntryDialog().show();
    if (entry == null || !mounted) return;

    try {
      final response = Actions.invoke(
        context,
        OpenVideoIntent(videoEntry: entry),
      ) as Future?;
      await response;
    } catch (e) {
      getIt<Toast>().show('加载失败');
      rethrow;
    }
  }

  Widget _getUsersWidget(List<User> userList) {
    final currentUser = context.read<ChatUser>().value!;
    final textStyle = Theme.of(context).textTheme.bodyMedium!;

    final others = List<User>.from(userList)..removeId(currentUser.id);

    return Text.rich(
      TextSpan(
        text: '当前观看：',
        children: [
          TextSpan(
            text: currentUser.name,
            style: textStyle.copyWith(color: currentUser.getColor(0.95)),
          ),
          for (final user in others)
            TextSpan(
              text: ' ${user.name}',
              style: textStyle.copyWith(color: user.getColor(0.95)),
            ),
        ],
      ),
    );
  }
}

class _VideoUnsyncNotification extends StatelessWidget {
  final VoidCallback onAction;
  final String? otherUserName;
  final String otherVideoTitle;

  const _VideoUnsyncNotification({
    required this.onAction,
    required this.otherUserName,
    required this.otherVideoTitle,
  });

  @override
  Widget build(BuildContext context) {
    final dialogContent = SizedBox(
      width: 260,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('你和 ${otherUserName ?? '对方'} 正在播放不同的视频。'),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: '对方正在播放 ',
                children: <TextSpan>[
                  TextSpan(
                    text: otherVideoTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onAction();
                },
                child: const Text('打开对应的视频'),
              ),
            ),
          ],
        ),
      ),
    );

    return TextButton.icon(
      onPressed: () => showModal(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.topRight,
          insetPadding: const EdgeInsets.symmetric(vertical: 36, horizontal: 8),
          child: dialogContent,
        ),
      ),
      style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error),
      icon: const Icon(Icons.warning, size: 16),
      label: const Text('播放不同步'),
    );
  }
}
