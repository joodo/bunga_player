import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'header/header.dart';
import 'progress_bar.dart';
import 'video_control.dart';

class ChromeLayer extends StatelessWidget {
  static const videoControlHeight = 64.0;

  const ChromeLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final chrome = [
      const Header()
          .backgroundGradient(
            LinearGradient(
              begin: .topCenter,
              end: .bottomCenter,
              colors: [Colors.black, Colors.transparent],
            ),
          )
          .positioned(top: 0, left: 0, right: 0),
      const VideoControl()
          .backgroundColor(Colors.black87)
          .clipRect()
          .positioned(height: videoControlHeight, bottom: 0, left: 0, right: 0),
      const VideoProgressBar().positioned(
        height: 16.0,
        bottom: videoControlHeight - 8.0,
        left: 0,
        right: 0,
      ),
    ].toStack(fit: StackFit.expand);

    final circlularIndicator = CircularProgressIndicator(
      strokeCap: StrokeCap.round,
    ).constrained(height: 24.0, width: 24.0);

    return Consumer<ShouldShowHUDNotifier>(
      builder: (context, showNotfier, child) => ValueListenableBuilder(
        valueListenable: showNotfier,
        builder: (context, show, child) =>
            [
                  Consumer<BusyStateNotifier>(
                    builder: (context, busyState, child) => circlularIndicator
                        .opacity(
                          !show && busyState.isBusy ? 1.0 : 0.0,
                          animate: true,
                        )
                        .padding(all: 16.0)
                        .alignment(Alignment.bottomLeft),
                  ),
                  chrome.opacity(show ? 1.0 : 0.0, animate: true),
                ]
                .toStack()
                .animate(const Duration(milliseconds: 300), Curves.easeOutCubic)
                .ignorePointer(ignoring: !show),
      ),
    );
  }
}
