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
          const VideoControl().positioned(
            height: videoControlHeight,
            left: 0,
            right: 0,
            bottom: 0,
          ),
          const VideoProgressBar().positioned(
            height: 32.0,
            top: 0,
            left: 0,
            right: 0,
          ),
        ]
        .toStack(clipBehavior: .none)
        .constrained(height: videoControlHeight + 16.0);
  }
}
