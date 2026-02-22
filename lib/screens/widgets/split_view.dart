import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/business/drag_business.dart';

typedef SplitPlacement = ({AxisDirection direction, double size});

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
  late final _sizeNotifier = ValueNotifier(widget.size);

  DragBusiness? _dragBusiness;

  Axis get _axis => widget.direction == .left || widget.direction == .right
      ? .horizontal
      : .vertical;

  late final _placementNotifier = ValueNotifier<SplitPlacement>((
    direction: widget.direction,
    size: widget.size,
  ));
  void _updateLayout() => _placementNotifier.value = (
    direction: widget.direction,
    size: _sizeNotifier.value,
  );

  @override
  void dispose() {
    _sizeNotifier.dispose();
    _placementNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateLayout();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final isReverse = widget.direction == .right || widget.direction == .down;

    // Pre-build static components.
    final Widget memoizedHandle = _createHandle();
    final Widget memoizedChild = RepaintBoundary(child: child!).flexible();
    final Widget? memoizedSplit = widget.split != null
        ? ValueListenableProvider.value(
            value: _placementNotifier,
            child: RepaintBoundary(child: widget.split!),
          )
        : null;

    return ValueListenableBuilder(
      valueListenable: _sizeNotifier,
      builder: (context, size, child) {
        final split = switch (_axis) {
          Axis.horizontal => memoizedSplit?.constrained(width: size),
          Axis.vertical => memoizedSplit?.constrained(height: size),
        };

        final list = [
          if (split != null) KeyedSubtree.wrap(split, 1),
          if (split != null) KeyedSubtree.wrap(memoizedHandle, 2),
          KeyedSubtree.wrap(child!, 3),
        ];

        return Flex(
          direction: _axis,
          children: isReverse ? list.reversed.toList() : list,
        );
      },
      child: memoizedChild,
    );
  }

  Widget _createHandle({Key? key}) {
    final inkWell = InkWell(
      onTap: () {},
      mouseCursor: switch (_axis) {
        Axis.horizontal => SystemMouseCursors.resizeLeftRight,
        Axis.vertical => SystemMouseCursors.resizeUpDown,
      },
      child: RotatedBox(
        quarterTurns: switch (_axis) {
          Axis.horizontal => 0,
          Axis.vertical => 1,
        },
        child: Icon(
          Icons.drag_indicator,
          size: 12.0,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ).center(),
      ),
    );
    final constrainedInkWell = switch (_axis) {
      Axis.horizontal => inkWell.constrained(width: _handleSize),
      Axis.vertical => inkWell.constrained(height: _handleSize),
    };

    final gestureDetector = GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onHorizontalDragStart: _axis == .horizontal
          ? (details) {
              _dragBusiness = DragBusiness<double>(
                startPosition: details.globalPosition,
                orientation: _axis,
                startValue: _sizeNotifier.value,
                onUpdate: (startValue, distance) {
                  if (widget.direction == .right) distance = -distance;
                  final newSize = startValue + distance;
                  _sizeNotifier.value = newSize.clamp(
                    widget.minSize,
                    widget.maxSize,
                  );
                },
              );
            }
          : null,
      onHorizontalDragUpdate: _axis == .horizontal
          ? (details) {
              _dragBusiness!.updatePosition(details.globalPosition);
            }
          : null,
      onHorizontalDragEnd: _axis == .horizontal
          ? (details) {
              _dragBusiness!.updatePosition(details.globalPosition);
              _updateLayout();
            }
          : null,

      onVerticalDragStart: _axis == .vertical
          ? (details) {
              _dragBusiness = DragBusiness<double>(
                startPosition: details.globalPosition,
                orientation: _axis,
                startValue: _sizeNotifier.value,
                onUpdate: (startValue, distance) {
                  if (widget.direction == .up) distance = -distance;
                  final newSize = startValue + distance;
                  _sizeNotifier.value = newSize.clamp(
                    widget.minSize,
                    widget.maxSize,
                  );
                },
              );
            }
          : null,
      onVerticalDragUpdate: _axis == .vertical
          ? (details) {
              _dragBusiness!.updatePosition(details.globalPosition);
            }
          : null,
      onVerticalDragEnd: _axis == .vertical
          ? (details) {
              _dragBusiness!.updatePosition(details.globalPosition);
              _updateLayout();
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
