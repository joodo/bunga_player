import 'package:bunga_player/screens/progress_section/video_progress_indicator.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:flutter/material.dart';

class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UINotifiers().isBusy,
      builder: (context, isBusy, child) => isBusy
          ? const Center(
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(),
              ),
            )
          : const VideoProgressIndicator(),
    );
  }
}
