import 'dart:async';

import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
import 'package:bunga_player/screens/wrappers/providers.dart';
import 'package:bunga_player/screens/wrappers/shortcuts.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
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
    return Row(
      children: [
        // Watcher list
        Consumer<CurrentChannelWatchers>(
          builder: (
            BuildContext context,
            CurrentChannelWatchers watchers,
            Widget? child,
          ) {
            if (watchers.value.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _getUsersWidget(watchers.value),
            );
          },
        ),
        const Spacer(),

        // Unsync hint
        Consumer2<CurrentChannelData, PlayVideoEntry>(
          builder: (context, channelData, videoEntry, child) {
            if (!context
                    .watch<BusinessIndicator>()
                    .isRunning || // busy, maybe loading video
                context.isVideoSameWithChannel) {
              return const SizedBox.shrink();
            }

            assert(channelData.value != null,
                'If channelData is null, then isVideoSameWithChannel should be true');

            return _VideoUnsyncNotification(
              otherUserName: channelData.value!.sharer.name,
              otherVideoTitle: channelData.value!.name,
              onAction: () => _onOpenVideoPressed(channelData.value!),
            );
          },
        ),
      ],
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
    if (entry == null) return;

    try {
      final response = Actions.invoke(
        // ignore: use_build_context_synchronously
        Intentor.context,
        OpenVideoIntent(videoEntry: entry),
      ) as Future?;
      await response;
    } catch (e) {
      getIt<Toast>().show('加载失败');
      rethrow;
    }
  }

  Widget _getUsersWidget(List<User> userList) {
    final currentUser = context.read<CurrentUser>().value!;
    final textStyle = Theme.of(context).textTheme.bodyMedium!;

    final others = List.from(userList)
      ..removeWhere((u) => u.id == currentUser.id);

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
      onPressed: () => showDialog(
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
