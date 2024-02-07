import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:bunga_player/screens/dialogs/bilibili.dart';
import 'package:bunga_player/screens/wrappers/toast.dart';
import 'package:bunga_player/services/bilibili.dart';
import 'package:bunga_player/actions/open_local_video.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoOpenControl extends StatefulWidget {
  const VideoOpenControl({super.key});

  @override
  State<VideoOpenControl> createState() => _VideoOpenControlState();
}

class _VideoOpenControlState extends State<VideoOpenControl> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        ),
        Selector<BusinessIndicator, bool>(
          selector: (context, bi) => bi.currentProgress != null,
          builder: (context, isBusy, child) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: isBusy ? null : _openLocalVideo,
                child: const Text('视频文件'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: isBusy ? null : _openBilibili,
                child: const Text('Bilibili 视频'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openLocalVideo() async {
    final currentChannel = context.read<CurrentChannel>();
    final videoPlayer = context.read<VideoPlayer>();
    final remotePlaying = context.read<RemotePlaying>();

    final shouldUpdateChannelData = remotePlaying.isVideoSameWithRoom;

    final file = await openLocalVideoDialog();
    if (file == null) return;

    try {
      await remotePlaying.openLocalVideo(file);

      // Update room data only if playing correct video
      if (shouldUpdateChannelData) {
        currentChannel.updateData(ChannelData(
          videoType: VideoType.local,
          name: file.name,
          videoHash: videoPlayer.videoHashNotifier.value!,
        ));
      }

      _onVideoLoaded();
    } catch (e) {
      context.showToast('加载失败');
      rethrow;
    }
  }

  void _openBilibili() async {
    final currentChannel = context.read<CurrentChannel>();
    final remotePlaying = context.read<RemotePlaying>();
    final showToast = context.showToast;

    // Update room data only if playing correct video
    final shouldUpdateRoomData = remotePlaying.isVideoSameWithRoom;

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => const BiliDialog(),
    );
    if (result == null) return;

    final biliEntry =
        await getService<Bilibili>().getEntryFromUri(result.parseUri());
    try {
      await remotePlaying.openOnlineVideo(biliEntry);
    } catch (e) {
      showToast('解析失败');
      rethrow;
    }

    if (shouldUpdateRoomData) {
      currentChannel.updateData(ChannelData(
        videoType: VideoType.bilibili,
        name: biliEntry.title,
        videoHash: biliEntry.hash,
        pic: biliEntry.pic,
      ));
    }

    _onVideoLoaded();
  }

  void _onVideoLoaded() {
    Navigator.of(context).pop();
  }
}
