import 'package:animations/animations.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:styled_widget/styled_widget.dart';

class PopupWidget extends SingleChildStatefulWidget {
  final bool showing;
  final Alignment alignment;
  final EdgeInsets padding;

  const PopupWidget({
    super.key,
    super.child,
    this.showing = false,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(16.0),
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
      overlayChildBuilder: (context) => Padding(
        padding: widget.padding,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, Widget? child) => FadeScaleTransition(
            animation: _animationController,
            child: child,
          ),
          child: child,
        ).alignment(widget.alignment),
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
