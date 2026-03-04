import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/ui/global_business.dart';

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
  bool _isPlay = false;

  late final _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final _scaleAnimation = Tween<double>(begin: 0.6, end: 1.2).animate(
    CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
  );
  late final _opacityAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
  ]).animate(_animController);

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

  void _handleTrigger(bool isPlay) {
    _isPlay = isPlay;
    _portalController.show();
    _animController.forward(from: 0.0).then((_) {
      _portalController.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: (context) {
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) => _buildIcon()
              .scale(all: _scaleAnimation.value)
              .opacity(_opacityAnimation.value),
        ).center();
      },
    );
  }

  Widget _buildIcon() {
    final colorScheme = Theme.of(context).colorScheme;
    return Icon(
          _isPlay ? Icons.play_arrow_rounded : Icons.pause_rounded,
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
