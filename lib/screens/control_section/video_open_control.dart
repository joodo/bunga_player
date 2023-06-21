import 'package:bunga_player/common/video_open.dart';
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
      await for (String hint in openLocalVideo(true)) {
        UINotifiers().hintText.value = hint;
      }
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
      await for (String hint in openBiliVideo(context, true)) {
        UINotifiers().hintText.value = hint;
      }
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
