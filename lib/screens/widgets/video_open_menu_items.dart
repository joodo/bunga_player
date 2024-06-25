import 'package:animations/animations.dart';
import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/player/models/video_entries/video_entry.dart';
import 'package:bunga_player/alist/client.dart';
import 'package:bunga_player/online_video/client.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
import 'package:bunga_player/screens/dialogs/net_disk.dart';
import 'package:bunga_player/screens/dialogs/online_video_dialog.dart';
import 'package:bunga_player/screens/widgets/loading_button_icon.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/material.dart';
import 'package:bunga_player/mocks/menu_anchor.dart' as mock;
import 'package:provider/provider.dart';

class VideoOpenMenuItemsCreator {
  final BuildContext context;
  final Function(BuildContext context, VideoEntry entry)? onVideoOpened;
  const VideoOpenMenuItemsCreator(this.context, {this.onVideoOpened});

  List<Widget> create() {
    return [
      Selector<AListClient?, bool>(
        selector: (context, client) => client != null,
        builder: (context, initiated, child) => mock.MenuItemButton(
          onPressed: initiated ? _openNetDisk : null,
          leadingIcon: initiated
              ? const Icon(Icons.cloud_outlined)
              : const LoadingButtonIcon(),
          child: const Text('网盘'),
        ),
      ),
      Selector<OnlineVideoClient?, bool>(
        selector: (context, client) => client != null,
        builder: (context, initiated, child) => mock.MenuItemButton(
          onPressed: initiated ? _openOnline : null,
          leadingIcon: initiated
              ? const Icon(Icons.language_outlined)
              : const LoadingButtonIcon(),
          child: const Text('在线视频'),
        ),
      ),
      mock.MenuItemButton(
        leadingIcon: const Icon(Icons.folder_outlined),
        onPressed: _openLocalVideo,
        child: const Text('本地文件    '),
      ),
    ];
  }

  void _openLocalVideo() async {
    _openChannel(entryGetter: LocalVideoEntryDialog().show);
  }

  void _openOnline() {
    _openChannel(
      entryGetter: () => showModal<VideoEntry?>(
        context: context,
        builder: (context) => const OnlineVideoDialog(),
      ),
    );
  }

  void _openNetDisk() async {
    _openChannel(
      entryGetter: () => showModal<VideoEntry?>(
        context: context,
        builder: (context) => const NetDiskDialog(),
      ),
    );
  }

  Future<void> _openChannel({
    required Future<VideoEntry?> Function() entryGetter,
  }) async {
    final result = await entryGetter();
    if (result == null || !context.mounted) return;

    try {
      final response = Actions.invoke(
        context,
        OpenVideoIntent(videoEntry: result),
      ) as Future?;
      await response;

      if (!context.mounted) {
        throw Exception('Context unmounted! Fall to call video open callback.');
      }
      onVideoOpened?.call(context, result);
    } catch (e) {
      getIt<Toast>().show('解析失败');
      rethrow;
    }
  }
}
