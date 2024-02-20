import 'dart:async';

import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/screens/dialogs/online_video_dialog.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
import 'package:bunga_player/screens/dialogs/net_disk.dart';
import 'package:bunga_player/screens/wrappers/providers.dart';
import 'package:bunga_player/screens/wrappers/shortcuts.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
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
    return Selector<BusinessIndicator, bool>(
      selector: (context, bi) => bi.currentProgress != null,
      builder: (context, isBusy, child) => Row(
        children: [
          const SizedBox(width: 8),
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: Navigator.of(context).pop,
          ),
          const Spacer(),
          FilledButton.icon(
            icon: const Icon(Icons.folder_outlined),
            label: const Text('本地文件'),
            onPressed: isBusy ? null : _openLocalVideo,
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            icon: const Icon(Icons.language_outlined),
            label: const Text('在线视频'),
            onPressed: isBusy ? null : _openOnline,
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            icon: const Icon(Icons.cloud_outlined),
            label: const Text('网盘'),
            onPressed: isBusy ? null : _openNetDisk,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _openLocalVideo() async {
    _openVideo(entryGetter: LocalVideoEntryDialog().show);
  }

  void _openOnline() async {
    _openVideo(
      entryGetter: () => showDialog<VideoEntry?>(
        context: context,
        builder: (context) => const OnlineVideoDialog(),
      ),
    );
  }

  void _openNetDisk() async {
    _openVideo(
      entryGetter: () => showDialog<VideoEntry?>(
        context: context,
        builder: (dialogContext) => NetDiskDialog(read: context.read),
      ),
    );
  }

  void _openVideo({required Future<VideoEntry?> Function() entryGetter}) async {
    final currentUser = context.read<CurrentUser>().value!;

    // Update room data only if playing correct video
    final shouldUpdateChannelData = context.isVideoSameWithChannel;

    final videoEntry = await entryGetter();
    if (videoEntry == null) return;

    try {
      final response = Actions.invoke(
        // ignore: use_build_context_synchronously
        Intentor.context,
        OpenVideoIntent(
          videoEntry: videoEntry,
          askPosition: !shouldUpdateChannelData,
        ),
      ) as Future?;
      await response;
    } catch (e) {
      getIt<Toast>().show('加载失败');
      rethrow;
    }

    if (shouldUpdateChannelData) {
      Actions.invoke(
        // ignore: use_build_context_synchronously
        Intentor.context,
        UpdateChannelDataIntent(ChannelData.fromShare(currentUser, videoEntry)),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }
}
