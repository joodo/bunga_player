import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/screens/progress_section/video_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgressSection extends StatelessWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BusinessIndicator, PlayIsBuffering>(
      builder: (context, bi, isBuffering, child) {
        final busy = bi.currentProgress != null || isBuffering.value;
        return busy
            ? Center(
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                      value: bi.totalProgress != null
                          ? bi.currentProgress! / bi.totalProgress!
                          : null),
                ),
              )
            : const VideoProgressIndicator();
      },
    );
  }
}
