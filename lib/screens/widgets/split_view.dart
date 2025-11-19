import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:styled_widget/styled_widget.dart';

class SplitView extends SingleChildStatefulWidget {
  final double minSize, size, maxSize;
  final AxisDirection direction;

  const SplitView({
    super.key,
    super.child,
    required this.minSize,
    required this.size,
    required this.maxSize,
    required this.direction,
  });

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends SingleChildState<SplitView> {
  static const double _handleSize = 12.0;
  late double _currentSize = widget.size;

  Offset _startDragPosition = Offset.zero;
  double _startDragSize = 0.0;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();
    if (widget.direction != .left &&
      widget.direction != .right) {
      throw UnimplementedError('Only left and right directions are supported');
    }

    final icon = InkWell(
      onTap: () {},
      mouseCursor: SystemMouseCursors.resizeLeftRight,
      child: Icon(
        Icons.drag_indicator,
        size: 12.0,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ).center(),
    ).constrained(width: _handleSize);
    final gestureDetector = GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onHorizontalDragStart: (details) {
        _startDragPosition = details.globalPosition;
        _startDragSize = _currentSize;
      },
      onHorizontalDragUpdate: (details) {
        final delta = details.globalPosition.dx - _startDragPosition.dx;
        setState(() {
          final newSize = _startDragSize +
              delta * (widget.direction == .right ? 1 : -1);
          _currentSize = newSize.clamp(widget.minSize, widget.maxSize);
        });
      },
      child: icon,
    );
    final handle = Ink(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: gestureDetector,
    );
    return [
      if (widget.direction == .left) handle,
      child.flexible(),
      if (widget.direction == .right) handle,
    ].toRow().constrained(width: _currentSize + _handleSize);
  }
}

extension SplitViewExtension on Widget {
  Widget splitView({
    Key? key,
    required double minSize,
    required double size,
    required double maxSize,
    required AxisDirection direction,
  }) {
    return SplitView(
      key: key,
      minSize: minSize,
      size: size,
      maxSize: maxSize,
      direction: direction,
      child: this,
    );
  }
}
