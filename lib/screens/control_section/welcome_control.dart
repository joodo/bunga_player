import 'dart:async';

import 'package:bunga_player/models/bili_entry.dart';
import 'package:bunga_player/actions/open_local_video.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/controllers/player_controller.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:bunga_player/utils/exceptions.dart';
import 'package:bunga_player/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WelcomeControl extends StatefulWidget {
  const WelcomeControl({super.key});

  @override
  State<WelcomeControl> createState() => _WelcomeControlState();
}

class _WelcomeControlState extends State<WelcomeControl> {
  String get _welcomeText => '${Chat().currentUserNameNotifier.value}, 你好！';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      UINotifiers().hintText.value = _welcomeText;
      windowManager.setTitle('Bunga Player');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UINotifiers().isBusy,
      builder: (context, isBusy, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: isBusy ? null : _onChangeName,
            child: const Text('换个名字'),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: isBusy ? null : _openLocalVideo,
            child: const Text('打开视频文件'),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: isBusy ? null : _openBilibili,
            child: const Text('Bilibili 视频'),
          ),
        ],
      ),
    );
  }

  void _openLocalVideo() async {
    try {
      final file = await openLocalVideoDialog();
      if (file == null) throw NoFileSelectedException();

      UINotifiers().isBusy.value = true;
      UINotifiers().hintText.value = '正在收拾客厅……';
      await VideoPlayer().loadLocalVideo(file);

      UINotifiers().hintText.value = '正在发送请柬……';
      final hash = VideoPlayer().videoHashNotifier.value!;
      await Chat().createOrJoinRoomByHash(
        hash,
        extraData: {
          'name': file.name,
          'hash': hash,
          'video_type': 'local',
        },
      );
      PlayerController().askPosition();

      UINotifiers().hintText.value = null;
      _onVideoLoaded();
    } catch (e) {
      if (e is! NoFileSelectedException) {
        logger.e(e);
        showSnackBar('加载失败');
      }
      UINotifiers().hintText.value = _welcomeText;
    } finally {
      UINotifiers().isBusy.value = false;
    }
  }

  void _openBilibili() async {
    try {
      final result = await showDialog(
        context: context,
        builder: (context) => const _BiliDialog(),
      );
      if (result == null) throw NoFileSelectedException();

      UINotifiers().isBusy.value = true;
      final BiliEntry biliEntry;
      String? channelId;
      if (result is String && result.isNotEmpty) {
        // Open video by url
        biliEntry = await BiliEntry.fromUrl(result.parseUri());
      } else if (result is _BiliChannelData) {
        // Join others
        biliEntry = BiliEntry.fromHash(result.hash);
        channelId = result.id;
      } else {
        throw 'Unknown dialog result';
      }
      await for (var hintText in PlayerController().loadBiliEntry(biliEntry)) {
        UINotifiers().hintText.value = hintText;
      }

      UINotifiers().hintText.value = '正在发送请柬……';
      if (channelId == null) {
        await Chat().createOrJoinRoomByHash(
          biliEntry.hash,
          extraData: {
            'video_type': 'bilibili',
            'hash': biliEntry.hash,
            'name': biliEntry.title,
            'pic': biliEntry.pic,
          },
        );
      } else {
        await Chat().joinRoomById(channelId);
      }
      PlayerController().askPosition();

      UINotifiers().hintText.value = null;
      _onVideoLoaded();
    } catch (e) {
      if (e is! NoFileSelectedException) {
        logger.e(e);
        showSnackBar('解析失败');
      }
      UINotifiers().hintText.value = _welcomeText;
    } finally {
      UINotifiers().isBusy.value = false;
    }
  }

  void _onChangeName() async {
    final previousName = Chat().currentUserNameNotifier.value;
    Chat().clearUserName();
    Navigator.of(context).popAndPushNamed(
      'control:rename',
      arguments: {'previousName': previousName},
    );
  }

  void _onVideoLoaded() {
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
      final channels = await Chat().fetchBiliChannels();

      if (!mounted) return;
      setState(() {
        _channels = channels
            .map((channel) => _BiliChannelData(
                  id: channel.id!,
                  hash: channel.extraData['hash'] as String,
                  name: channel.name!,
                  pic: channel.extraData['pic'] as String,
                  creator: channel.createdBy!.name,
                ))
            .toList();
        _isPulling = false;
      });
    }

    final timer = Timer.periodic(const Duration(seconds: 5), updateChannel);
    updateChannel(timer);
    return timer;
  }
}
