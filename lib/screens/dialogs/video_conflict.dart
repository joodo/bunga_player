import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class VideoConflictDialog extends StatelessWidget {
  static WidgetBuilder builder = (context) => const VideoConflictDialog();

  const VideoConflictDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.difference),
      title: const Text('文件不匹配'),
      content: const Text('''你要打开的视频文件和对方不同。
这通常意味着你们会看到不同的内容。不过，如果你清楚打开的只是同一内容的不同版本（比如 720P 和蓝光版），那么也可以同步播放来试试看。
确认要打开视频吗？''').constrained(maxWidth: 360.0),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('不了'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('打开'),
        ),
      ],
    );
  }
}
