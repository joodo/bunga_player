import 'package:bunga_player/common/video_open.dart';
import 'package:bunga_player/singletons/im_controller.dart';
import 'package:bunga_player/singletons/im_video_connector.dart';
import 'package:bunga_player/singletons/logger.dart';
import 'package:bunga_player/singletons/snack_bar.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:flutter/material.dart';

class VideoOpenControl extends StatefulWidget {
  final VoidCallback? onLoadSuccessed;
  final VoidCallback? onBackPressed;

  const VideoOpenControl({
    super.key,
    this.onBackPressed,
    this.onLoadSuccessed,
  });

  @override
  State<VideoOpenControl> createState() => _VideoOpenControlState();
}

class _VideoOpenControlState extends State<VideoOpenControl> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UINotifiers().isBusy,
      builder: (context, isBusy, child) => Row(
        children: [
          const SizedBox(width: 8),
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBackPressed,
          ),
          const SizedBox(width: 8),
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
    );
  }

  void _openLocalVideo() async {
    UINotifiers().isBusy.value = true;
    try {
      // Update room data only if playing correct video
      final shouldUpdateRoomData = IMVideoConnector().isVideoSameWithRoom;

      final data = await openLocalVideo();

      if (shouldUpdateRoomData) {
        UINotifiers().hintText.value = '正在发送请柬……';
        await IMController().currentChannel!.updatePartial(set: {
          'name': data.name,
          'hash': data.hash,
          'video_type': 'local',
        });
      }
      IMVideoConnector().askPosition();

      widget.onLoadSuccessed?.call();
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
      final shouldUpdateRoomData = IMVideoConnector().isVideoSameWithRoom;

      final biliChannel = await openBiliVideo(context);

      if (shouldUpdateRoomData) {
        UINotifiers().hintText.value = '正在发送请柬……';
        await IMController().currentChannel!.updatePartial(set: {
          'video_type': 'bilibili',
          'hash': biliChannel.hash,
          'name': biliChannel.name,
          'pic': biliChannel.pic,
        });
      }
      IMVideoConnector().askPosition();

      widget.onLoadSuccessed?.call();
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
}
