import 'dart:async';

import 'package:bunga_player/actions/auth.dart';
import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/mocks/menu_anchor.dart' as mock;
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/dialogs/online_video_dialog.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
import 'package:bunga_player/screens/dialogs/net_disk.dart';
import 'package:bunga_player/screens/dialogs/settings.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeControl extends StatefulWidget {
  const WelcomeControl({super.key});

  @override
  State<WelcomeControl> createState() => _WelcomeControlState();
}

class _WelcomeControlState extends State<WelcomeControl> {
  Completer<void>? _completer;
  void _initBusinessIndicator() {
    User? getCurrentUser() => context.read<CurrentUser>().value;
    final bi = context.read<BusinessIndicator>();

    if (getCurrentUser() == null) {
      bi.run(
        tasks: [
          (data) async {
            Actions.maybeInvoke(context, AutoLoginIntent());
            return getCurrentUser()!.name;
          },
          bi.setTitleFromLastTask((lastResult) => '$lastResult, 你好！'),
          (data) {
            _completer = Completer();
            return _completer!.future;
          }
        ],
        showProgress: false,
      );
    } else {
      bi.run(
        tasks: [
          bi.setTitle('${getCurrentUser()!.name}, 你好！'),
          (data) {
            _completer = Completer();
            return _completer!.future;
          }
        ],
        showProgress: false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_initBusinessIndicator);
  }

  @override
  Widget build(BuildContext context) {
    final actions = Selector<BusinessIndicator, bool>(
      selector: (context, bi) => bi.currentProgress != null,
      builder: (context, isBusy, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: isBusy ? null : _onChangeName,
            child: const Text('换个名字'),
          ),
          const SizedBox(width: 16),
          mock.MyMenuAnchor(
            style: MenuStyle(
              elevation: MaterialStateProperty.all(12),
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 12)),
            ),
            rootOverlay: true,
            alignmentOffset: const Offset(0, 8),
            anchorTapClosesMenu: true,
            builder: (context, controller, child) => FilledButton(
              onPressed: isBusy
                  ? null
                  : controller.isOpen
                      ? controller.close
                      : controller.open,
              child: const Text('打开视频'),
            ),
            menuChildren: [
              mock.MenuItemButton(
                leadingIcon: const Icon(Icons.cloud_outlined),
                onPressed: _openNetDisk,
                child: const Text('网盘'),
              ),
              mock.MenuItemButton(
                leadingIcon: const Icon(Icons.language_outlined),
                onPressed: _openOnline,
                child: const Text('在线视频'),
              ),
              mock.MenuItemButton(
                leadingIcon: const Icon(Icons.folder_outlined),
                onPressed: _openLocalVideo,
                child: const Text('本地文件  '),
              ),
            ],
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: isBusy ? null : _joinOthersChannel,
            child: const Text('其他人'),
          ),
        ],
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        actions,
        Positioned(
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showDialog(
              context: context,
              builder: (dialogContext) => SettingsDialog(context.read),
            ),
          ),
        ),
      ],
    );
  }

  void _openLocalVideo() async {
    _openChannel(entryGetter: LocalVideoEntryDialog().show);
  }

  void _openOnline() {
    _openChannel(
      entryGetter: () => showDialog<VideoEntry?>(
        context: context,
        builder: (context) => const OnlineVideoDialog(),
      ),
    );
  }

  void _openNetDisk() async {
    _openChannel(
      entryGetter: () => showDialog<VideoEntry?>(
        context: context,
        builder: (dialogContext) => NetDiskDialog(read: context.read),
      ),
    );
  }

  void _joinOthersChannel() async {
    _openChannel(
      entryGetter: () => showDialog<(String, VideoEntry)?>(
        context: context,
        builder: (context) => const _OthersDialog(),
      ),
    );
  }

  Future<void> _openChannel({
    required Future Function() entryGetter,
  }) async {
    final currentUser = context.read<CurrentUser>().value!;

    final result = await entryGetter();
    if (result == null) return;

    void doOpen() async {
      try {
        if (result is VideoEntry) {
          final response = Actions.invoke(
            Intentor.context,
            OpenVideoIntent(
              videoEntry: result,
              beforeAskingPosition: () => Actions.invoke(
                Intentor.context,
                JoinChannelIntent.byChannelData(
                  ChannelData.fromShare(currentUser, result),
                ),
              ) as Future<void>,
            ),
          ) as Future?;
          await response;
        } else {
          final response = Actions.invoke(
            Intentor.context,
            OpenVideoIntent(
              videoEntry: result.$2,
              beforeAskingPosition: () => Actions.invoke(
                Intentor.context,
                JoinChannelIntent.byId(result.$1),
              ) as Future?,
            ),
          ) as Future<void>;
          await response;
        }

        if (mounted) Navigator.of(context).popAndPushNamed('control:main');
      } catch (e) {
        getIt<Toast>().show('解析失败');
        Future.microtask(_initBusinessIndicator);
        rethrow;
      }
    }

    _completer?.complete();
    Future.microtask(doOpen);
  }

  void _onChangeName() async {
    _completer?.complete();
    context.read<IsCatAwake>().value = false;
    Navigator.of(context).popAndPushNamed(
      'control:rename',
      arguments: {'previousName': context.read<CurrentUser>().value!.name},
    );
  }
}

class _OthersDialog extends StatefulWidget {
  const _OthersDialog();
  @override
  State<_OthersDialog> createState() => _OthersDialogState();
}

class _OthersDialogState extends State<_OthersDialog> {
  List<(String id, ChannelData data)>? _channels;
  late final Timer _timer;
  bool _isPulling = false;

  final _scrollController = ScrollController();

  @override
  void initState() {
    _timer = _createUpdateTimer();
    super.initState();
  }

  @override
  dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final channelsScroll = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Row(
        children: [
          const SizedBox(width: 8),
          if (_channels != null)
            ..._channels!
                .map((channel) => _createVideoCard(channel.$1, channel.$2)),
          const SizedBox(width: 8),
        ],
      ),
    );
    // HACK: cannot use listview because bug, same as popmoji
    // https://github.com/flutter/flutter/issues/26527
    final channelsView = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: themeData.colorScheme.surface,
      ),
      child: Stack(
        children: [
          Scrollbar(
            controller: _scrollController,
            child: Center(child: channelsScroll),
          ),
          if (_channels?.isEmpty ?? false)
            Center(
              child: Text(
                '暂时没有其他人分享视频',
                style: themeData.textTheme.labelMedium,
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            height: _isPulling ? 4 : 0,
            child: const LinearProgressIndicator(),
          ),
        ],
      ),
    );

    return AlertDialog(
      title: const Text('加入其他人'),
      content: SizedBox(
        width: 500,
        height: 220,
        child: _channels == null
            ? const Center(child: CircularProgressIndicator())
            : channelsView,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ],
    );
  }

  Widget _createVideoCard(String channelId, ChannelData channelData) {
    final themeData = Theme.of(context);
    // FIXME: Unhandle exception when image url not usable
    // see https://github.com/flutter/flutter/issues/129967
    final videoImage = Image.network(
      channelData.image ?? '',
      height: 125,
      width: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox(
        width: 200,
        height: 125,
        child: Center(
          child: Icon(Icons.broken_image, size: 64),
        ),
      ),
    );

    final cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        videoImage,
        SizedBox(
          width: 160,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    channelData.sharer.name,
                    style: themeData.textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '分享',
                  style: themeData.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Tooltip(
              message: channelData.name,
              child: Text(
                channelData.name,
                overflow: TextOverflow.ellipsis,
                style: themeData.textTheme.titleSmall,
              ),
            ),
          ),
        ),
      ],
    );

    final themedCard = FutureBuilder<ColorScheme>(
      future: ColorScheme.fromImageProvider(
        brightness: themeData.brightness,
        provider: videoImage.image,
      ),
      initialData: themeData.colorScheme,
      builder: (context, colorScheme) {
        final builder = Builder(
          builder: (context) {
            final themeData = Theme.of(context);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              clipBehavior: Clip.hardEdge,
              color: ElevationOverlay.applySurfaceTint(
                themeData.colorScheme.surfaceVariant,
                themeData.colorScheme.surfaceTint,
                0,
              ),
              elevation: 0,
              child: InkWell(
                onTap: () => Navigator.pop<(String, VideoEntry)>(
                  context,
                  (
                    channelId,
                    VideoEntry.fromChannelData(channelData),
                  ),
                ),
                child: cardContent,
              ),
            );
          },
        );
        return Theme(
          data: themeData.copyWith(
            colorScheme: colorScheme.data,
          ),
          child: builder,
        );
      },
    );

    return themedCard;
  }

  Timer _createUpdateTimer() {
    void updateChannel(_) async {
      setState(() {
        _isPulling = true;
      });

      final chatService = getIt<ChatService>();
      final channels = await chatService.queryOnlineChannels();

      if (!mounted) return;
      setState(() {
        _channels = channels;
        _isPulling = false;
      });
    }

    final timer = Timer.periodic(const Duration(seconds: 5), updateChannel);
    updateChannel(timer);
    return timer;
  }
}
