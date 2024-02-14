import 'dart:async';

import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
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
    final videoPlayer = context.read<VideoPlayer>();

    return Row(
      children: [
        // Watcher list
        Consumer2<CurrentUser, CurrentChannelWatchers>(
          builder: (
            BuildContext context,
            CurrentUser currentUser,
            CurrentChannelWatchers watchers,
            Widget? child,
          ) {
            if (currentUser.value == null) return const SizedBox.shrink();

            String text =
                _getUsersStringExceptId(watchers.value, currentUser.value!.id);
            if (text.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('$text 在和你一起看'),
            );
          },
        ),
        const Spacer(),

        // Unsync hint
        Selector<CurrentChannelData, ChannelData?>(
          selector: (BuildContext context, CurrentChannelData notifier) =>
              notifier.value,
          builder:
              (BuildContext context, ChannelData? channelData, Widget? child) {
            if (context.watch<BusinessIndicator>().currentProgress !=
                    null || // busy, maybe loading video
                videoPlayer.isStoppedNotifier.value || // stopped
                channelData == null || // no one change data
                channelData.videoHash == videoPlayer.videoHashNotifier.value) {
              return const SizedBox.shrink();
            }

            return _VideoUnsyncNotification(
              onAction: () => _onOpenVideoPressed(channelData),
              otherUserName: channelData.sharer.name,
              otherVideoTitle: channelData.name,
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
      // ignore: use_build_context_synchronously
      final response = Actions.invoke(
        Intentor.context,
        OpenVideoIntent(videoEntry: entry),
      ) as Future?;
      await response;
    } catch (e) {
      getIt<Toast>().show('加载失败');
      rethrow;
    }
  }

  String _getUsersStringExceptId(List<User> userList, String id) {
    String result = '';
    for (var user in userList) {
      if (user.id == id) continue;
      result += '${user.name}, ';
    }

    try {
      result = result.substring(0, result.length - 2);
    } catch (e) {
      return '';
    }

    return result;
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
