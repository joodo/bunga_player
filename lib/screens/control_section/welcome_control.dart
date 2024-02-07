import 'dart:async';

import 'package:bunga_player/mocks/menu_anchor.dart' as mock;
import 'package:bunga_player/models/playing/online_video_entry.dart';
import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:bunga_player/screens/dialogs/bilibili.dart';
import 'package:bunga_player/screens/dialogs/net_disk.dart';
import 'package:bunga_player/screens/wrappers/toast.dart';
import 'package:bunga_player/services/bilibili.dart';
import 'package:bunga_player/actions/open_local_video.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/services/stream_io.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeControl extends StatefulWidget {
  const WelcomeControl({super.key});

  @override
  State<WelcomeControl> createState() => _WelcomeControlState();
}

class _WelcomeControlState extends State<WelcomeControl> {
  Completer<void>? _completer;
  late final _mission = Mission(
    name: '${context.read<CurrentUser>().name}, 你好！',
    tasks: [
      () {
        _completer = Completer();
        return _completer!.future;
      }
    ],
  );
  void _initBusinessIndicator() => context.read<BusinessIndicator>().run(
        missions: [_mission],
        showProgress: false,
      );

  @override
  void initState() {
    super.initState();
    Future.microtask(_initBusinessIndicator);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<BusinessIndicator, bool>(
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
                onPressed: _openLocalVideo,
                child: const Text('视频文件'),
              ),
              mock.MenuItemButton(
                onPressed: _openBilibili,
                child: const Text('Bilibili 链接'),
              ),
              mock.MenuItemButton(
                onPressed: _openNetDisk,
                child: const Text('网盘文件'),
              ),
            ],
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: isBusy ? null : _showOthers,
            child: const Text('其他人'),
          ),
        ],
      ),
    );
  }

  void _openLocalVideo() async {
    final currentChannel = context.read<CurrentChannel>();
    final videoPlayer = context.read<VideoPlayer>();
    final remotePlaying = context.read<RemotePlaying>();

    final file = await openLocalVideoDialog();
    if (file == null) return;

    void doOpen() async {
      try {
        await remotePlaying.openLocalVideo(
          file,
          joinChannel: () {
            final hash = videoPlayer.videoHashNotifier.value!;
            return currentChannel.createOrJoin(ChannelData(
              videoType: VideoType.local,
              name: file.name,
              videoHash: hash,
            ));
          },
        );
        _onVideoLoaded();
      } catch (e) {
        context.showToast('加载失败');
        Future.microtask(_initBusinessIndicator);
        rethrow;
      }
    }

    _completer?.complete();
    Future.microtask(doOpen);
  }

  void _openBilibili() async {
    final currentChannel = context.read<CurrentChannel>();
    final remotePlaying = context.read<RemotePlaying>();
    final showToast = context.showToast;

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => const BiliDialog(),
    );
    if (result == null) return;

    void doOpen() async {
      try {
        await remotePlaying.openOnlineVideo(
          null,
          entryGetter: () {
            print('dfas');
            return getService<Bilibili>().getEntryFromUri(result.parseUri());
          },
          joinChannel: (videoEntry) {
            return currentChannel.createOrJoin(ChannelData(
              videoType: VideoType.bilibili,
              name: videoEntry.title,
              videoHash: videoEntry.hash,
              pic: videoEntry.pic,
            ));
          },
        );
        _onVideoLoaded();
      } catch (e) {
        showToast('解析失败');
        Future.microtask(_initBusinessIndicator);
        rethrow;
      }
    }

    _completer?.complete();
    Future.microtask(doOpen);
  }

  void _openNetDisk() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const NetDiskDialog(),
    );
    print(result);
  }

  void _showOthers() async {
    final currentChannel = context.read<CurrentChannel>();
    final remotePlaying = context.read<RemotePlaying>();
    final showToast = context.showToast;

    final result = await showDialog<_BiliChannelData?>(
      context: context,
      builder: (context) => const _OthersDialog(),
    );
    if (result == null) return;

    void doOpen() async {
      try {
        final onlineEntry = OnlineVideoEntry.fromHash(result.hash);
        await remotePlaying.openOnlineVideo(
          onlineEntry,
          joinChannel: (videoEntry) {
            return currentChannel.joinById(result.id);
          },
        );
        _onVideoLoaded();
      } catch (e) {
        showToast('打开失败');
        Future.microtask(_initBusinessIndicator);
        rethrow;
      }
    }

    _completer?.complete();
    Future.microtask(doOpen);
  }

  void _onChangeName() async {
    _completer?.complete();
    Navigator.of(context).popAndPushNamed(
      'control:rename',
      arguments: {'previousName': context.read<CurrentUser>().name},
    );
  }

  void _onVideoLoaded() {
    Navigator.of(context).popAndPushNamed('control:main');
  }
}

class _BiliChannelData {
  final String id;
  final String hash;
  final String name;
  final String pic;
  final String? creator;

  _BiliChannelData({
    required this.id,
    required this.hash,
    required this.name,
    required this.pic,
    this.creator,
  });
}

class _OthersDialog extends StatefulWidget {
  const _OthersDialog();
  @override
  State<_OthersDialog> createState() => _OthersDialogState();
}

class _OthersDialogState extends State<_OthersDialog> {
  List<_BiliChannelData>? _channels;
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
            ..._channels!.map((info) => _createVideoCard(info)),
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
          onPressed: () => Navigator.pop<_BiliChannelData?>(context),
          child: const Text('取消'),
        ),
      ],
    );
  }

  Widget _createVideoCard(_BiliChannelData channelInfo) {
    final themeData = Theme.of(context);
    final videoImage = Image.network(
      channelInfo.pic,
      height: 125,
      width: 200,
      fit: BoxFit.cover,
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
                    channelInfo.creator!,
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
              message: channelInfo.name,
              child: Text(
                channelInfo.name,
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
                onTap: () =>
                    Navigator.pop<_BiliChannelData?>(context, channelInfo),
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

      final chatService = getService<StreamIO>();
      final channels = await chatService.fetchBiliChannels();

      if (!mounted) return;
      setState(() {
        _channels = channels.map<_BiliChannelData>((channel) {
          final (id, creator, data) = channel;
          return _BiliChannelData(
            id: id,
            hash: data.videoHash,
            name: data.name,
            pic: data.pic!,
            creator: creator,
          );
        }).toList();
        _isPulling = false;
      });
    }

    final timer = Timer.periodic(const Duration(seconds: 5), updateChannel);
    updateChannel(timer);
    return timer;
  }
}
