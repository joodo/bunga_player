import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'header/header.dart';
import 'progress_bar.dart';
import 'video_control.dart';

class PlayerUI extends StatelessWidget {
  static const videoControlHeight = 64.0;

  const PlayerUI({super.key});

  @override
  Widget build(BuildContext context) {
    final ui = [
      const Header()
          .backgroundGradient(LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.transparent,
            ],
          ))
          .positioned(top: 0, left: 0, right: 0),
      const VideoControl()
          .backgroundColor(Colors.black87)
          .clipRect()
          .positioned(
            height: videoControlHeight,
            bottom: 0,
            left: 0,
            right: 0,
          ),
      const VideoProgressBar().positioned(
        height: 16.0,
        bottom: videoControlHeight - 8.0,
        left: 0,
        right: 0,
      ),
    ].toStack(fit: StackFit.expand);

    return Consumer<ShouldShowHUDNotifier>(
      builder: (context, showNotfier, child) => ValueListenableBuilder(
        valueListenable: showNotfier,
        builder: (context, show, child) => IgnorePointer(
          ignoring: !show,
          child: [
            Consumer<BusyCount>(builder: (context, busyCount, child) {
              return CircularProgressIndicator(
                strokeWidth: 3.0,
                strokeCap: StrokeCap.round,
              )
                  .constrained(height: 12.0, width: 12.0)
                  .opacity(!show && busyCount.isBusy ? 1.0 : 0.0, animate: true)
                  .padding(all: 16.0)
                  .alignment(Alignment.bottomLeft);
            }),
            ui.opacity(show ? 1.0 : 0.0, animate: true),
          ].toStack().animate(
                const Duration(milliseconds: 300),
                Curves.easeOutCubic,
              ),
        ),
      ),
    );
  }
}
