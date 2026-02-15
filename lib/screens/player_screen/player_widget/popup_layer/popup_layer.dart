import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'adjust_indicator.dart';
import 'play_pause_overlay.dart';
import 'play_sync_message.dart';

class PopupLayer extends StatelessWidget {
  const PopupLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return [AdjustIndicator(), PlaySyncMessage(), PlayPauseOverlay()].toStack();
  }
}
