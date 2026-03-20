import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/ui/global_business.dart';

class PlaybackOverlayManager {
  final Duration pendingPlayShowDelay;
  final BuildContext context;

  PlaybackOverlayManager({
    required this.pendingPlayShowDelay,
    required this.context,
  });

  bool _isPending = false;

  void show(PlayPauseOverlayStatus status) {
    if (!context.mounted) return;

    final signal = context.read<PlayToggleVisualSignal>();

    switch (status) {
      case .pause:
        _isPending = false;
        signal.fire(.pause);
      case .playing:
        signal.fire(.playing);
      case .pendingPlaying:
        _isPending = true;
        Future.delayed(pendingPlayShowDelay, () {
          if (!context.mounted) return;
          if (_isPending) signal.fire(.pendingPlaying);
        });
    }
  }
}
