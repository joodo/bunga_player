import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:styled_widget/styled_widget.dart';

class SplitView extends SingleChildStatefulWidget {
  final double minSize, size, maxSize;
  final AxisDirection direction;
  final Widget? split;

  const SplitView({
    super.key,
    super.child,
    this.split,
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
    final isHorizontal =
        widget.direction == .left || widget.direction == .right;
    final isReverse = widget.direction == .right || widget.direction == .down;

    final split = isHorizontal
        ? widget.split?.constrained(width: _currentSize)
        : widget.split?.constrained(height: _currentSize);

    final list = [
      if (split != null) KeyedSubtree.wrap(split, 1),
      if (split != null) KeyedSubtree.wrap(_createHandle(), 2),
      KeyedSubtree.wrap(child!.flexible(), 3),
    ];

    final flex = Flex(
      direction: isHorizontal ? .horizontal : .vertical,
      children: isReverse ? list.reversed.toList() : list,
    );

    return flex;
  }

  Widget _createHandle({Key? key}) {
    final isHorizontal =
        widget.direction == .left || widget.direction == .right;

    final inkWell = InkWell(
      onTap: () {},
      mouseCursor: isHorizontal
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      child: RotatedBox(
        quarterTurns: isHorizontal ? 0 : 1,
        child: Icon(
          Icons.drag_indicator,
          size: 12.0,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ).center(),
      ),
    );
    final constrainedInkWell = isHorizontal
        ? inkWell.constrained(width: _handleSize)
        : inkWell.constrained(height: _handleSize);

    final gestureDetector = GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onHorizontalDragStart: isHorizontal
          ? (details) {
              _startDragPosition = details.globalPosition;
              _startDragSize = _currentSize;
            }
          : null,
      onHorizontalDragUpdate: isHorizontal
          ? (details) {
              final delta = details.globalPosition.dx - _startDragPosition.dx;
              setState(() {
                final newSize =
                    _startDragSize +
                    delta * (widget.direction == .left ? 1 : -1);
                _currentSize = newSize.clamp(widget.minSize, widget.maxSize);
              });
            }
          : null,
      onVerticalDragStart: !isHorizontal
          ? (details) {
              _startDragPosition = details.globalPosition;
              _startDragSize = _currentSize;
            }
          : null,
      onVerticalDragUpdate: !isHorizontal
          ? (details) {
              final delta = details.globalPosition.dy - _startDragPosition.dy;
              setState(() {
                final newSize =
                    _startDragSize + delta * (widget.direction == .up ? 1 : -1);
                _currentSize = newSize.clamp(widget.minSize, widget.maxSize);
              });
            }
          : null,
      child: constrainedInkWell,
    );

    return Ink(
      key: key,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: gestureDetector,
    );
  }
}

extension SplitViewExtension on Widget {
  Widget splitView({
    Key? key,
    required double minSize,
    required double size,
    required double maxSize,
    required AxisDirection direction,
    Widget? split,
  }) {
    return SplitView(
      key: key,
      minSize: minSize,
      size: size,
      maxSize: maxSize,
      direction: direction,
      split: split,
      child: this,
    );
  }
}
