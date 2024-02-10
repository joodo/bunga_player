import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/screens/dialogs/bilibili.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
import 'package:bunga_player/screens/dialogs/net_disk.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
              FilledButton.icon(
                icon: const Icon(Icons.folder_outlined),
                label: const Text('本地文件'),
                onPressed: isBusy ? null : _openLocalVideo,
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                icon: SvgPicture.asset(
                  'assets/images/bilibili.svg',
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.cover,
                ),
                label: const Text('Bilibili'),
                onPressed: isBusy ? null : _openBilibili,
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                icon: const Icon(Icons.cloud_outlined),
                label: const Text('网盘'),
                onPressed: isBusy ? null : _openNetDisk,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openLocalVideo() async {
    _openVideo(entryGetter: LocalVideoEntryDialog().show);
  }

  void _openBilibili() async {
    _openVideo(
      entryGetter: () => showDialog<VideoEntry?>(
        context: context,
        builder: (context) => const BiliDialog(),
      ),
    );
  }

  void _openVideo({required Future<VideoEntry?> Function() entryGetter}) async {
    final currentUser = context.read<CurrentUser>();
    final currentChannel = context.read<CurrentChannel>();
    final remotePlaying = context.read<RemotePlaying>();

    final videoEntry = await entryGetter();
    if (videoEntry == null) return;

    // Update room data only if playing correct video
    final shouldUpdateChannelData = remotePlaying.isVideoSameWithChannel;

    try {
      await remotePlaying.openVideo(
        videoEntry,
        askPosition: !shouldUpdateChannelData,
      );
    } catch (e) {
      getService<Toast>().show('加载失败');
      rethrow;
    }

    if (shouldUpdateChannelData) {
      currentChannel.updateData(currentUser.getSharingData(videoEntry));
    }

    _onVideoLoaded();
  }

  void _openNetDisk() async {
    final currentChannel = context.read<CurrentChannel>();
    final currentUser = context.read<CurrentUser>();
    final remotePlaying = context.read<RemotePlaying>();
    final watchProgress = context.read<VideoPlayer>().watchProgress;

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
        // TODO: add path field to channel data, then remove this
        beforeAskingPosition: () => getService<Bunga>().setStringHash(
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
