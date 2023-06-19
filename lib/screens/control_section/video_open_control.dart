import 'dart:async';
import 'dart:io';

import 'package:bunga_player/common/bili_video.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/logger.dart';
import 'package:bunga_player/common/snack_bar.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/control_section/indexed_stack_item.dart';
import 'package:crclib/catalog.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

final welcomeText = '${IMController().currentUserNotifier.value?.name}, 你好！';

class BiliChannelInfo {
  final String id;
  final String name;
  final String pic;
  final String creator;
  final String bvid;
  final int p;

  BiliChannelInfo({
    required this.id,
    required this.name,
    required this.pic,
    required this.creator,
    required this.bvid,
    required this.p,
  });
}

class VideoOpenControl extends StatefulWidget with IndexedStackItem {
  final VoidCallback? onLoadSuccessed;
  final VoidCallback? onLoggedOut;
  final ValueNotifier<bool> isBusyNotifier;
  final ValueNotifier<String?> hintTextNotifier;

  const VideoOpenControl({
    super.key,
    required this.isBusyNotifier,
    this.onLoggedOut,
    this.onLoadSuccessed,
    required this.hintTextNotifier,
  });

  @override
  State<VideoOpenControl> createState() => _VideoOpenControlState();

  @override
  void onEnter() {
    hintTextNotifier.value = welcomeText;
  }

  @override
  void onLeave() {
    hintTextNotifier.value = null;
  }
}

class _VideoOpenControlState extends State<VideoOpenControl> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.isBusyNotifier,
      builder: (context, isBusy, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: isBusy ? null : _logout,
            child: const Text('换个名字'),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: isBusy ? null : _openVideo,
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

  void _openVideo() async {
    const typeGroup = XTypeGroup(
      label: 'videos',
      extensions: <String>[
        'webm',
        'mkv',
        'flv',
        'vob',
        'ogv',
        'ogg',
        'rrc',
        'gifv',
        'mpeg',
        'rm',
        'qt',
        'mng',
        'mov',
        'avi',
        'wmv',
        'yuv',
        'asf',
        'amv',
        'mp4',
        'm4p',
        'm4v',
        'mpg',
        'mp2',
        'mpe',
        'mpv',
        'm4v',
        'svi',
        '3gp',
        '3g2',
        'mxf',
        'roq',
        'nsv',
        'flv',
        'f4v',
        'f4p',
        'f4a',
        'f4b',
        'mod',
      ],
    );
    final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      try {
        widget.isBusyNotifier.value = true;

        widget.hintTextNotifier.value = '正在收拾客厅……';

        final crcValue = await File(file.path)
            .openRead()
            .take(1000)
            .transform(Crc32Xz())
            .single;
        final crcString = crcValue.toString();

        await VideoController().loadVideo(file.path);

        widget.hintTextNotifier.value = '正在发送请柬……';
        await IMController().createOrJoinGroup(
          crcString,
          extraData: {
            'name': file.name,
            'video_type': 'local',
          },
        );
        await IMController().askPosition();

        windowManager.setTitle(file.name);
        widget.onLoadSuccessed?.call();
      } catch (e) {
        logger.e(e);
        showSnackBar('加载失败');
        widget.hintTextNotifier.value = welcomeText;
      } finally {
        widget.isBusyNotifier.value = false;
      }
    }
  }

  void _openBilibili() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const BiliDialog(),
    );

    String failedString = '';
    try {
      widget.isBusyNotifier.value = true;

      widget.hintTextNotifier.value = '正在鬼鬼祟祟……';
      final BiliVideo biliVideo;
      if (result is String && result.isNotEmpty) {
        // Parse bilibili url
        failedString = '解析失败';
        biliVideo = await BiliVideo.fromUrl(Uri.parse(result));
      } else if (result is BiliChannelInfo) {
        // Parse bvid and p
        failedString = '加入失败';
        biliVideo = BiliVideo(bvid: result.bvid, p: result.p);
      } else {
        widget.isBusyNotifier.value = false;
        return;
      }

      await biliVideo.fetch();
      if (!biliVideo.isHD) {
        showSnackBar('无法获取高清视频');
        logger.w('Bilibili: Cookie of serverless funtion outdated');
      }

      widget.hintTextNotifier.value = '正在收拾客厅……';
      await VideoController().loadVideo(biliVideo.videoUrls);

      widget.hintTextNotifier.value = '正在发送请柬……';
      await IMController().createOrJoinGroup(
        'bili_${biliVideo.cid}',
        extraData: {
          'video_type': 'bilibili',
          'name': biliVideo.title,
          'pic': biliVideo.pic,
          'bvid': biliVideo.bvid,
          'p': biliVideo.p,
        },
      );
      await IMController().askPosition();

      windowManager.setTitle(biliVideo.title);

      widget.onLoadSuccessed?.call();
    } catch (e) {
      logger.e(e);
      showSnackBar(failedString);
      widget.hintTextNotifier.value = welcomeText;
    } finally {
      widget.isBusyNotifier.value = false;
    }
  }

  void _logout() async {
    await IMController().logout();
    SharedPreferences.getInstance().then((pref) => pref.remove('user_name'));
    widget.onLoggedOut?.call();
  }
}

class BiliDialog extends StatefulWidget {
  const BiliDialog({super.key});

  @override
  State<BiliDialog> createState() => _BiliDialogState();
}

class _BiliDialogState extends State<BiliDialog> {
  List<BiliChannelInfo> _channels = [];
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
    final body = AlertDialog(
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
            // HACK: cannot use listview because bug
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
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp):
            DoNothingAndStopPropagationIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown):
            DoNothingAndStopPropagationIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft):
            DoNothingAndStopPropagationIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight):
            DoNothingAndStopPropagationIntent(),
        SingleActivator(LogicalKeyboardKey.space):
            DoNothingAndStopPropagationIntent(),
      },
      child: body,
    );
  }

  void _onSubmitBiliUrl() {
    Navigator.pop(context, _textController.text);
  }

  Widget _createVideoCard(BiliChannelInfo channelInfo) {
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
                    channelInfo.creator,
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
      final channels = await IMController().fetchChannels();

      if (!mounted) return;
      setState(() {
        _channels = channels
            .map((channel) => BiliChannelInfo(
                  id: channel.id!,
                  name: channel.name!,
                  pic: channel.extraData['pic'] as String,
                  creator: channel.createdBy!.name,
                  bvid: channel.extraData['bvid'] as String,
                  p: channel.extraData['p'] as int,
                ))
            .toList();
      });
    }

    final timer = Timer.periodic(const Duration(seconds: 5), updateChannel);
    updateChannel(timer);
    return timer;
  }
}
