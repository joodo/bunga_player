import 'dart:async';

import 'package:animations/animations.dart';
import 'package:bunga_player/play/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class PlayPauseOverlay extends StatefulWidget {
  const PlayPauseOverlay({super.key});

  @override
  State<PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<PlayPauseOverlay>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription _subscription = context
      .read<PlayToggleVisualSignal>()
      .listen(_handleTrigger);
  bool _showPlayIcon = false;

  late final _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final _transitionAnimation = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeOut,
  );

  final _portalController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _animController;
    _subscription;
  }

  @override
  void dispose() {
    _subscription.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _handleTrigger(bool isPlaying) async {
    _showPlayIcon = isPlaying;

    _portalController.show();
    await _animController.forward(from: 0.0);
    await _animController.reverse(from: 1.0);
    _portalController.hide();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: (context) {
        return FadeScaleTransition(
          animation: _transitionAnimation,
          child: _buildIcon(),
        ).center();
      },
    );
  }

  Widget _buildIcon() {
    final colorScheme = Theme.of(context).colorScheme;
    return Icon(
          _showPlayIcon ? Icons.play_arrow_rounded : Icons.pause_rounded,
          size: 80,
          color: colorScheme.onSurface,
        )
        .padding(all: 16.0)
        .decorated(
          color: colorScheme.scrim.withAlpha(120),
          shape: BoxShape.circle,
        );
  }
}
