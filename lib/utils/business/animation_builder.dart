import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class InfiniteAnimationBuilder extends SingleChildStatefulWidget {
  final Duration duration;
  final Widget Function(BuildContext context, double value, Widget? child)
  builder;

  const InfiniteAnimationBuilder({
    super.key,
    required this.duration,
    required this.builder,
    super.child,
  });

  @override
  State<InfiniteAnimationBuilder> createState() =>
      _InfiniteAnimationBuilderState();
}

class _InfiniteAnimationBuilderState
    extends SingleChildState<InfiniteAnimationBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, child) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => widget.builder(context, _controller.value, child),
  );
}
