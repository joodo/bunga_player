import 'package:bunga_player/common/video_open.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/controllers/player_controller.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
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

      final biliChannel = await openBiliVideo(context);

      if (shouldUpdateRoomData) {
        UINotifiers().hintText.value = '正在发送请柬……';
        await Chat().updateChannelData({
          'video_type': 'bilibili',
          'hash': biliChannel.hash,
          'name': biliChannel.name,
          'pic': biliChannel.pic,
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
