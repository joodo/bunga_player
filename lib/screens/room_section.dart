import 'package:bunga_player/actions/open_local_video.dart';
import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class RoomSection extends StatefulWidget {
  const RoomSection({super.key});

  @override
  State<RoomSection> createState() => _RoomSectionState();
}

class _RoomSectionState extends State<RoomSection> {
  @override
  Widget build(BuildContext context) {
    final currentChannel = context.read<CurrentChannel>();
    final isBusy = context.read<BusinessIndicator>().currentProgress != null;
    final videoPlayer = context.read<VideoPlayer>();

    return Row(
      children: [
        // Watcher list
        ValueListenableBuilder(
          valueListenable: currentChannel.watchersNotifier,
          builder: (context, watchers, child) {
            String text = _getUsersStringExceptId(
                watchers, context.read<CurrentUser>().id);
            if (text.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('$text 在和你一起看'),
            );
          },
        ),
        const Spacer(),

        // Unsync hint
        ValueListenableBuilder(
          valueListenable: currentChannel.channelDataNotifier,
          builder: (context, channelData, child) {
            if (isBusy == true || // maybe loading video
                videoPlayer.isStoppedNotifier.value || // stopped
                channelData == null || // no one change data
                channelData.videoHash == videoPlayer.videoHashNotifier.value) {
              return const SizedBox.shrink();
            }

            return _VideoUnsyncNotification(
              onAction: () => _onOpenVideoPressed(channelData.videoHash),
              otherUserName: currentChannel.lastChannelDataUpdater?.name,
              otherVideoTitle: channelData.name,
            );
          },
        ),
      ],
    );
  }

  void _onOpenVideoPressed(String videoHash) {
    return videoHash.split('-').first == 'local'
        ? _openLocalVideo()
        : context.read<RemotePlaying>().followRemoteOnlineVideoHash(videoHash);
  }

  void _openLocalVideo() async {
    final remotePlaying = context.read<RemotePlaying>();

    final file = await openLocalVideoDialog();
    if (file == null) return;

    try {
      await remotePlaying.openLocalVideo(file);
    } catch (e) {
      getService<Toast>().show('加载失败');
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
