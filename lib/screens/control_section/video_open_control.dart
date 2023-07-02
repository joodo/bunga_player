import 'package:bunga_player/models/bili_entry.dart';
import 'package:bunga_player/utils/video_open.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/controllers/player_controller.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/utils/exceptions.dart';
import 'package:bunga_player/utils/string.dart';
import 'package:flutter/material.dart';

class VideoOpenControl extends StatefulWidget {
  const VideoOpenControl({super.key});

  @override
  State<VideoOpenControl> createState() => _VideoOpenControlState();
}

class _VideoOpenControlState extends State<VideoOpenControl> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UINotifiers().isBusy,
      builder: (context, isBusy, child) => Stack(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: isBusy ? null : _openLocalVideo,
                child: const Text('视频文件'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: isBusy ? null : _openBilibili,
                child: const Text('Bilibili 视频'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openLocalVideo() async {
    UINotifiers().isBusy.value = true;
    try {
      // Update room data only if playing correct video
      final shouldUpdateRoomData = PlayerController().isVideoSameWithRoom;

      final data = await openLocalVideo();

      if (shouldUpdateRoomData) {
        UINotifiers().hintText.value = '正在发送请柬……';
        await Chat().updateChannelData({
          'name': data.name,
          'hash': data.hash,
          'video_type': 'local',
        });
      }
      PlayerController().askPosition();

      _onVideoLoaded();
    } catch (e) {
      if (e is! NoFileSelectedException) {
        logger.e(e);
        showSnackBar('加载失败');
      }
    } finally {
      UINotifiers().hintText.value = null;
      UINotifiers().isBusy.value = false;
    }
  }

  void _openBilibili() async {
    UINotifiers().isBusy.value = true;
    try {
      // Update room data only if playing correct video
      final shouldUpdateRoomData = PlayerController().isVideoSameWithRoom;

      final result = await showDialog(
        context: context,
        builder: (context) => const _BiliDialog(),
      );
      if (result == null) throw NoFileSelectedException();

      final biliEntry = await BiliEntry.fromUrl(parseUrlFrom(result));
      await PlayerController().loadBiliEntry(biliEntry);

      if (shouldUpdateRoomData) {
        UINotifiers().hintText.value = '正在发送请柬……';
        await Chat().updateChannelData({
          'video_type': 'bilibili',
          'hash': biliEntry.hash,
          'name': biliEntry.title,
          'pic': biliEntry.pic,
        });
      }
      PlayerController().askPosition();

      _onVideoLoaded();
    } catch (e) {
      if (e is! NoFileSelectedException) {
        logger.e(e);
        showSnackBar('解析失败');
      }
    } finally {
      UINotifiers().hintText.value = null;
      UINotifiers().isBusy.value = false;
    }
  }

  void _onVideoLoaded() {
    Navigator.of(context).pop();
  }
}

class _BiliDialog extends StatefulWidget {
  const _BiliDialog();
  @override
  State<_BiliDialog> createState() => _BiliDialogState();
}

class _BiliDialogState extends State<_BiliDialog> {
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(40),
      title: const Text('打开 Bilibili 视频'),
      content: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
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
}
