import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'adjust_indicator.dart';
import 'play_pause_overlay.dart';
import 'play_sync_message.dart';
import 'busy_indicator.dart';
import 'spark_selection_bar.dart';

class PopupLayer extends StatelessWidget {
  const PopupLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isInChannel = context.read<IsInChannel>().value;
    return [
      AdjustIndicator(),
      if (isInChannel) PlaySyncMessage(),
      PlayPauseOverlay(),
      BusyIndicator(),
      if (isInChannel) SparkSelectionBar(),
    ].toStack();
  }
}
