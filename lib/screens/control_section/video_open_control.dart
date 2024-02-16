import 'dart:async';

import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/screens/dialogs/bilibili.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
import 'package:bunga_player/screens/dialogs/net_disk.dart';
import 'package:bunga_player/screens/wrappers/providers.dart';
import 'package:bunga_player/screens/wrappers/shortcuts.dart';
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
      // ignore: use_build_context_synchronously
      final response = Actions.invoke(
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
      // ignore: use_build_context_synchronously
      Actions.invoke(
        Intentor.context,
        UpdateChannelDataIntent(ChannelData.fromShare(currentUser, videoEntry)),
      );
    }

    if (context.mounted) Navigator.of(context).pop();
  }
}
