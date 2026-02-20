import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'package:bunga_player/utils/business/run_after_build.dart';

class PopupWidget extends SingleChildStatefulWidget {
  final bool showing;
  final Widget Function(BuildContext context, Widget child)? layoutBuilder;

  const PopupWidget({
    super.key,
    super.child,
    this.showing = false,
    this.layoutBuilder,
  });

  @override
  State<PopupWidget> createState() => _PopupWidgetState();
}

class _PopupWidgetState extends SingleChildState<PopupWidget>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    value: 0.0,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 75),
    vsync: this,
  );

  final OverlayPortalController _portalController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _animationController;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: (context) => AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          final animatedChild = FadeScaleTransition(
            animation: _animationController,
            child: child,
          );

          if (widget.layoutBuilder != null) {
            return widget.layoutBuilder!(context, animatedChild);
          } else {
            return Center(child: animatedChild);
          }
        },
        child: child,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant PopupWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.showing == widget.showing) return;

    if (widget.showing) {
      runAfterBuild(() {
        _portalController.show();
        _animationController.forward();
      });
    } else {
      _animationController.reverse().then((_) => _portalController.hide());
    }
  }
}
