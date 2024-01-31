import 'dart:async';

import 'package:bunga_player/services/bilibili.dart';
import 'package:bunga_player/actions/open_local_video.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/providers/ui/ui.dart';
import 'package:bunga_player/services/stream_io.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/providers/ui/toast.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/utils/exceptions.dart';
import 'package:bunga_player/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeControl extends StatefulWidget {
  const WelcomeControl({super.key});

  @override
  State<WelcomeControl> createState() => _WelcomeControlState();
}

class _WelcomeControlState extends State<WelcomeControl> {
  String get _welcomeText => '${context.read<CurrentUser>().name}, 你好！';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BusinessName>().value = _welcomeText);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IsBusy>(
      builder: (context, isBusy, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: isBusy.value ? null : _onChangeName,
            child: const Text('换个名字'),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: isBusy.value ? null : _openLocalVideo,
            child: const Text('打开视频文件'),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: isBusy.value ? null : _openBilibili,
            child: const Text('Bilibili 视频'),
          ),
        ],
      ),
    );
  }

  void _openLocalVideo() async {
    final currentChannel = context.read<CurrentChannel>();
    final isBusy = context.read<IsBusy>();
    final businessName = context.read<BusinessName>();
    final videoPlayer = context.read<VideoPlayer>();
    final playerController = context.read<RemotePlaying>();
    final showSnackBar = context.read<Toast>().show;

    try {
      final file = await openLocalVideoDialog();
      if (file == null) throw NoFileSelectedException();

      isBusy.value = true;
      businessName.value = '正在收拾客厅……';
      await videoPlayer.loadLocalVideo(file);

      businessName.value = '正在发送请柬……';
      final hash = videoPlayer.videoHashNotifier.value!;
      await currentChannel.createOrJoin(ChannelData(
        videoType: VideoType.local,
        name: file.name,
        videoHash: hash,
      ));
      playerController.askPosition();

      _onVideoLoaded();
    } catch (e) {
      businessName.value = _welcomeText;
      if (e is! NoFileSelectedException) {
        showSnackBar('加载失败');
        rethrow;
      }
    } finally {
      isBusy.value = false;
    }
  }

  void _openBilibili() async {
    final currentChannel = context.read<CurrentChannel>();
    final isBusy = context.read<IsBusy>();
    final businessName = context.read<BusinessName>();
    final playerController = context.read<RemotePlaying>();
    final toast = context.read<Toast>();

    try {
      final result = await showDialog(
        context: context,
        builder: (context) => const _BiliDialog(),
      );
      if (result == null) throw NoFileSelectedException();

      isBusy.value = true;
      final BiliEntry biliEntry;
      String? channelId;
      if (result is String && result.isNotEmpty) {
        // Open video by url
        biliEntry =
            await getService<Bilibili>().getEntryFromUri(result.parseUri());
      } else if (result is _BiliChannelData) {
        // Join others
        biliEntry = BiliEntry.fromHash(result.hash);
        channelId = result.id;
      } else {
        throw 'Unknown dialog result';
      }
      await for (var hintText in playerController.loadBiliEntry(biliEntry)) {
        businessName.value = hintText;
      }

      businessName.value = '正在发送请柬……';
      if (channelId == null) {
        await currentChannel.createOrJoin(ChannelData(
          videoType: VideoType.bilibili,
          name: biliEntry.title,
          videoHash: biliEntry.hash,
          pic: biliEntry.pic,
        ));
      } else {
        await currentChannel.joinById(channelId);
      }
      playerController.askPosition();

      businessName.value = null;
      _onVideoLoaded();
    } catch (e) {
      businessName.value = _welcomeText;
      if (e is! NoFileSelectedException) {
        toast.show('解析失败');
        rethrow;
      }
    } finally {
      isBusy.value = false;
    }
  }

  void _onChangeName() async {
    Navigator.of(context).popAndPushNamed(
      'control:rename',
      arguments: {'previousName': context.read<CurrentUser>().name},
    );
  }

  void _onVideoLoaded() {
    context.read<BusinessName>().value = null;
    Navigator.of(context).popAndPushNamed('control:main');
  }
}

class _BiliChannelData {
  final String? id;
  final String hash;
  final String name;
  final String pic;
  final String? creator;

  _BiliChannelData({
    this.id,
    required this.hash,
    required this.name,
    required this.pic,
    this.creator,
  });
}

class _BiliDialog extends StatefulWidget {
  const _BiliDialog();
  @override
  State<_BiliDialog> createState() => _BiliDialogState();
}

class _BiliDialogState extends State<_BiliDialog> {
  List<_BiliChannelData>? _channels;
  late final Timer _timer;
  bool _isPulling = false;

  final _textController = TextEditingController();
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
      content: SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              '加入其他人',
              style: themeData.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: _channels == null
                  ? const Center(child: CircularProgressIndicator())
                  : channelsView,
            ),
            const SizedBox(height: 24),
            Text(
              '或打开新视频',
              style: themeData.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '视频链接',
              ),
              onTap: () {
                _textController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _textController.text.length,
                );
              },
              onSubmitted: (text) {
                if (text.isNotEmpty) _onSubmitBiliUrl();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('取消'),
        ),
        ValueListenableBuilder(
          valueListenable: _textController,
          builder: (context, value, child) => TextButton(
            onPressed: value.text.isEmpty ? null : _onSubmitBiliUrl,
            child: const Text('解析'),
          ),
        ),
      ],
    );
  }

  void _onSubmitBiliUrl() {
    Navigator.pop(context, _textController.text);
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
                onTap: () => Navigator.pop(context, channelInfo),
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
