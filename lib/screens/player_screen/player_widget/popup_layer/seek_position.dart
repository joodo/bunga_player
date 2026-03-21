import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/screens/widgets/popup_widget.dart';
import 'package:bunga_player/screens/player_screen/play_progress_slide_business.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';

import 'blur_chip.dart';

class SeekPosition extends StatelessWidget {
  const SeekPosition({super.key});

  @override
  Widget build(BuildContext context) {
    final business = context.read<PlayProgressSlideBusiness>();

    final content = ValueListenableBuilder(
      valueListenable: business.positionNotifier,
      builder: (context, position, child) => Text(
        position.hhmmss,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    ).padding(horizontal: 24.0, vertical: 12.0).blurToast();

    final link = LayerLink();
    return ValueListenableBuilder(
      valueListenable: business.isSeekingNotifier,
      builder: (context, isSeeking, child) => PopupWidget(
        showing: isSeeking,
        layoutBuilder: (context, popup) => UnconstrainedBox(
          child: CompositedTransformFollower(
            link: link,
            targetAnchor: .bottomCenter,
            followerAnchor: .bottomCenter,
            offset: Offset(0, -80.0),
            child: popup,
          ),
        ),
        popupBuilder: (context) => content,

        child: child,
      ),
      child: CompositedTransformTarget(
        link: link,
        child: const SizedBox.expand(),
      ),
    );
  }
}
