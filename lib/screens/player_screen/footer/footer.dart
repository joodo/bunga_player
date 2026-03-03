import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'progress_bar.dart';
import 'video_control.dart';

class Footer extends StatelessWidget {
  static const videoControlHeight = 64.0;

  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      const VideoControl(),
      const VideoProgressBar().positioned(
        height: 16.0,
        top: -8.0,
        left: 0,
        right: 0,
      ),
    ].toStack(clipBehavior: .none).constrained(height: videoControlHeight);
  }
}
