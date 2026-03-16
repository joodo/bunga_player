import 'dart:async';

import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/ui/global_business.dart';

enum _OverlayPhase { hidden, entering, visible, exiting }

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
  _OverlayPhase _phase = _OverlayPhase.hidden;
  double? _frozenScaleOnExit;
  int _transitionId = 0;

  late final _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final _scaleAnimation = Tween<double>(begin: 0.6, end: 1.1).animate(
    CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
  );
  late final _opacityAnimation = CurvedAnimation(
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

  void _handleTrigger(PlayPauseOverlayStatus status) async {
    final transitionId = ++_transitionId;

    switch (status) {
      case PlayPauseOverlayStatus.pause:
        _showPlayIcon = false;

        _showOverlay();
        await _animateIn(transitionId, from: 0.0);
        if (_isStale(transitionId)) return;

        await Future<void>.delayed(const Duration(milliseconds: 120));
        if (_isStale(transitionId)) return;

        await _animateOut(transitionId, from: 1.0);

      case PlayPauseOverlayStatus.pendingPlaying:
        _showPlayIcon = true;

        _showOverlay();
        await _animateIn(transitionId, from: 0.0);

      case PlayPauseOverlayStatus.playing:
        _showPlayIcon = true;
        if (_phase == _OverlayPhase.hidden) return;

        await _animateOut(
          transitionId,
          from: _animController.value == 0.0 ? 1.0 : _animController.value,
        );
    }
  }

  bool _isStale(int transitionId) => !mounted || transitionId != _transitionId;

  void _showOverlay() {
    if (_phase != _OverlayPhase.hidden) return;

    _portalController.show();
    _phase = _OverlayPhase.entering;
  }

  void _hideOverlay() {
    if (_phase == _OverlayPhase.hidden) return;

    _portalController.hide();
    _phase = _OverlayPhase.hidden;
    _frozenScaleOnExit = null;
  }

  Future<void> _animateIn(int transitionId, {required double from}) async {
    _frozenScaleOnExit = null;
    _phase = _OverlayPhase.entering;
    await _animController.forward(from: from);
    if (_isStale(transitionId)) return;

    _phase = _OverlayPhase.visible;
  }

  Future<void> _animateOut(int transitionId, {required double from}) async {
    _freezeScaleForExit();
    _phase = _OverlayPhase.exiting;

    await _animController.reverse(from: from);
    if (_isStale(transitionId)) return;

    _hideOverlay();
  }

  void _freezeScaleForExit() {
    _frozenScaleOnExit = _scaleAnimation.value;
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: (context) {
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) => _buildIcon()
              .scale(all: _frozenScaleOnExit ?? _scaleAnimation.value)
              .opacity(_opacityAnimation.value),
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
        )
        .breath();
  }
}
