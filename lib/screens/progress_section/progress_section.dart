import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/screens/progress_section/video_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CatIndicator>(
      builder: (context, bi, child) {
        return bi.busy
            ? const Center(
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(),
                ),
              )
            : const VideoProgressIndicator();
      },
    );
  }
}
