import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class PopupWidget extends SingleChildStatefulWidget {
  final ValueListenable<bool> visibleNotifier;
  const PopupWidget({super.key, super.child, required this.visibleNotifier});

  @override
  State<PopupWidget> createState() => _PopupWidgetState();
}

class _PopupWidgetState extends SingleChildState<PopupWidget>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    value: 0.0,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 75),
    vsync: this,
  )..addStatusListener((AnimationStatus status) {
      setState(() {});
    });

  @override
  void initState() {
    super.initState();
    widget.visibleNotifier.addListener(_updateAnimationControl);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Visibility(
      visible: _controller.status != AnimationStatus.dismissed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) => FadeScaleTransition(
          animation: _controller,
          child: child,
        ),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    widget.visibleNotifier.removeListener(_updateAnimationControl);
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimationControl() {
    if (widget.visibleNotifier.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
}
