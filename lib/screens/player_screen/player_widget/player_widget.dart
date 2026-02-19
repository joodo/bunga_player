import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';

import 'danmaku_layer.dart';
import 'interactive_layer.dart';
import 'chrome_layer/chrome_layer.dart';
import 'popmoji_layer.dart';
import 'popup_layer/popup_layer.dart';
import '../business.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IsInChannel>(
      builder: (context, inChannel, child) => [
        child!,
        if (inChannel.value) const DanmakuLayer(),
        if (inChannel.value) const PopmojiLayer(),
        InteractiveLayer(),
        const ChromeLayer(),
        const PopupLayer(),
      ].toStack(fit: StackFit.expand),
      child: getIt<PlayService>().buildVideoWidget(),
    );
  }
}
