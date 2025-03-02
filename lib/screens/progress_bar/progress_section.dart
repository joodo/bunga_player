import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/screens/player_screen/player/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

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
            : const VideoProgressBar();
      },
    );
  }
}
