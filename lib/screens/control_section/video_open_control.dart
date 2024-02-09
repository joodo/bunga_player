import 'package:bunga_player/models/playing/local_video_entry.dart';
import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/screens/dialogs/bilibili.dart';
import 'package:bunga_player/screens/dialogs/net_disk.dart';
import 'package:bunga_player/services/alist.dart';
import 'package:bunga_player/services/bilibili.dart';
import 'package:bunga_player/actions/open_local_video.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
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
              const SizedBox(width: 16),
              FilledButton(
                onPressed: isBusy ? null : _openNetDisk,
                child: const Text('网盘视频'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openLocalVideo() async {
    final currentUser = context.read<CurrentUser>();
    final currentChannel = context.read<CurrentChannel>();
    final remotePlaying = context.read<RemotePlaying>();

    final shouldUpdateChannelData = remotePlaying.isVideoSameWithChannel;

    final file = await openLocalVideoDialog();
    if (file == null) return;

    final entry = LocalVideoEntry.fromFile(file);
    try {
      await remotePlaying.openVideo(
        entry,
        askPosition: !shouldUpdateChannelData,
      );

      // Update room data only if playing correct video
      if (shouldUpdateChannelData) {
        currentChannel.updateData(currentUser.getSharingData(entry));
      }

      _onVideoLoaded();
    } catch (e) {
      getService<Toast>().show('加载失败');
      rethrow;
    }
  }

  void _openBilibili() async {
    final currentUser = context.read<CurrentUser>();
    final currentChannel = context.read<CurrentChannel>();
    final remotePlaying = context.read<RemotePlaying>();

    // Update room data only if playing correct video
    final shouldUpdateChannelData = remotePlaying.isVideoSameWithChannel;

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => const BiliDialog(),
    );
    if (result == null) return;

    final biliEntry =
        await getService<Bilibili>().getEntryFromUri(result.parseUri());
    try {
      await remotePlaying.openVideo(
        biliEntry,
        askPosition: !shouldUpdateChannelData,
      );
    } catch (e) {
      getService<Toast>().show('解析失败');
      rethrow;
    }

    if (shouldUpdateChannelData) {
      currentChannel.updateData(currentUser.getSharingData(biliEntry));
    }

    _onVideoLoaded();
  }

  void _openNetDisk() async {
    final currentChannel = context.read<CurrentChannel>();
    final currentUser = context.read<CurrentUser>();
    final remotePlaying = context.read<RemotePlaying>();
    final watchProgress = context.read<VideoPlayer>().watchProgress;

    // Update room data only if playing correct video
    final shouldUpdateChannelData = remotePlaying.isVideoSameWithChannel;

    final alistPath = await showDialog(
      context: context,
      builder: (context) => NetDiskDialog(watchProgress: watchProgress),
    );
    if (alistPath == null) return;

    final alistEntry = AListEntry(path: alistPath);
    try {
      await remotePlaying.openVideo(
        alistEntry,
        beforeAskingPosition: (videoEntry) => getService<Bunga>().setStringHash(
          text: alistPath,
          hash: AListEntry.hashFromPath(alistPath),
        ),
        askPosition: !shouldUpdateChannelData,
      );
    } catch (e) {
      getService<Toast>().show('解析失败');
      rethrow;
    }

    if (shouldUpdateChannelData) {
      currentChannel.updateData(currentUser.getSharingData(alistEntry));
    }

    _onVideoLoaded();
  }

  void _onVideoLoaded() {
    Navigator.of(context).pop();
  }
}
