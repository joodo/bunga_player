import 'dart:async';

import 'package:bunga_player/common/bili_video.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class NoFileSelectedException implements Exception {}

class BiliChannelData {
  final String? id;
  final String hash;
  final String name;
  final String pic;
  final String? creator;

  BiliChannelData({
    this.id,
    required this.hash,
    required this.name,
    required this.pic,
    this.creator,
  });
}

class LocalVideoChannelData {
  final String name;
  final String hash;
  LocalVideoChannelData({required this.name, required this.hash});
}

Future<LocalVideoChannelData> openLocalVideo() async {
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
      'rm',
      'rmvb',
    ],
  );
  final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
  if (file == null) throw NoFileSelectedException();

  VideoPlayer().stop();

  UINotifiers().hintText.value = '正在收拾客厅……';
  await VideoPlayer().loadLocalVideo(file.path);
  final hash = VideoPlayer().videoHashNotifier.value!;

  windowManager.setTitle(file.name);

  return LocalVideoChannelData(name: file.name, hash: hash);
}

Future<BiliChannelData> openBiliVideo(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (context) => const BiliDialog(),
  );
  if (result == null) throw NoFileSelectedException();

  UINotifiers().hintText.value = '正在鬼鬼祟祟……';
  if (result is String && result.isNotEmpty) {
    // Open video by url
    final regex = RegExp(
        r'(http|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])');
    final url = regex.firstMatch(result)?.group(0);
    if (url == null) throw const FormatException('Illegal url');

    final biliVideo = await BiliVideo.fromUrl(Uri.parse(url));

    final hash = await loadBiliVideo(biliVideo);

    return BiliChannelData(
      hash: hash,
      name: biliVideo.title,
      pic: biliVideo.pic,
    );
  } else if (result is BiliChannelData) {
    // Join others
    final biliVideo = BiliVideo.fromHash(result.hash);

    await loadBiliVideo(biliVideo);

    return result;
  } else {
    throw 'Unknown dialog result';
  }
}

Future<String> loadBiliVideo(BiliVideo biliVideo) async {
  VideoPlayer().stop();

  UINotifiers().hintText.value = '正在鬼鬼祟祟……';
  await biliVideo.fetch();
  if (!biliVideo.isHD) {
    showSnackBar('无法获取高清视频');
    logger.w('Bilibili: Cookie of serverless funtion outdated');
  }

  UINotifiers().hintText.value = '正在收拾客厅……';
  final hash = await VideoPlayer().loadBiliVideo(biliVideo);

  windowManager.setTitle(biliVideo.title);
  return hash;
}

class BiliDialog extends StatefulWidget {
  const BiliDialog({super.key});

  @override
  State<BiliDialog> createState() => _BiliDialogState();
}

class _BiliDialogState extends State<BiliDialog> {
  List<BiliChannelData> _channels = [];
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
  }

  void _onSubmitBiliUrl() {
    Navigator.pop(context, _textController.text);
  }

  Widget _createVideoCard(BiliChannelData channelInfo) {
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
            .map((channel) => BiliChannelData(
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
