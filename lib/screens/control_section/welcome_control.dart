import 'dart:async';

import 'package:bunga_player/models/bili_entry.dart';
import 'package:bunga_player/screens/control_section/open_local_video.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/controllers/player_controller.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/utils/exceptions.dart';
import 'package:bunga_player/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class WelcomeControl extends StatefulWidget {
  const WelcomeControl({super.key});

  @override
  State<WelcomeControl> createState() => _WelcomeControlState();
}

class _WelcomeControlState extends State<WelcomeControl> {
  String get _welcomeText => '${Chat().currentUserNotifier.value?.name}, 你好！';

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
            onPressed: isBusy ? null : _logout,
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
    UINotifiers().isBusy.value = true;
    try {
      final data = await openLocalVideo();

      UINotifiers().hintText.value = '正在发送请柬……';
      await Chat().createOrJoinRoomByHash(
        data.hash,
        extraData: {
          'name': data.name,
          'hash': data.hash,
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
    UINotifiers().isBusy.value = true;
    try {
      final result = await showDialog(
        context: context,
        builder: (context) => const _BiliDialog(),
      );
      if (result == null) throw NoFileSelectedException();

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
      await PlayerController().loadBiliEntry(biliEntry);

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

  void _logout() async {
    await Chat().logout();
    SharedPreferences.getInstance().then((pref) => pref.remove('user_name'));
    _onLoggedOut();
  }

  void _onLoggedOut() {
    Navigator.of(context).popAndPushNamed('control:login');
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
  List<_BiliChannelData> _channels = [];
  late final Timer _timer;

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
    return AlertDialog(
      insetPadding: const EdgeInsets.all(40),
      content: SizedBox(
        width: double.maxFinite,
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
            // HACK: cannot use listview because bug, same as popmoji
            // https://github.com/flutter/flutter/issues/26527
            _channels.isEmpty
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Scrollbar(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        child: Row(
                          children: _channels
                              .map((info) => _createVideoCard(info))
                              .toList(),
                        ),
                      ),
                    ),
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
      });
    }

    final timer = Timer.periodic(const Duration(seconds: 5), updateChannel);
    updateChannel(timer);
    return timer;
  }
}
