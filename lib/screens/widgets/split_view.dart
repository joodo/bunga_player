import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/business/drag_business.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';

typedef SplitPlacement = ({AxisDirection direction, double size});

class SplitView extends SingleChildStatefulWidget {
  final double minSize, size, maxSize;
  final AxisDirection direction;
  final Widget? split;
  final bool resizable;

  const SplitView({
    super.key,
    super.child,
    this.split,
    this.resizable = true,
    required this.minSize,
    required this.size,
    required this.maxSize,
    required this.direction,
  });

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends SingleChildState<SplitView> {
  static const _handleSize = Size(12.0, 120.0);
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
    // Pre-build static components.
    final Widget memoizedHandle = _createHandle();
    final Widget memoizedChild = RepaintBoundary(child: child!);
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

        return [
          if (split != null)
            KeyedSubtree(
              key: Key('split'),
              child: split.positioned(
                left: widget.direction != .right ? 0 : null,
                right: widget.direction != .left ? 0 : null,
                top: widget.direction != .down ? 0 : null,
                bottom: widget.direction != .up ? 0 : null,
                width: _axis == .horizontal ? size : null,
                height: _axis == .vertical ? size : null,
              ),
            ),
          KeyedSubtree(
            key: Key('child'),
            child: child!.positioned(
              left: widget.direction != .left || split == null ? 0 : size,
              right: widget.direction != .right || split == null ? 0 : size,
              top: widget.direction != .up || split == null ? 0 : size,
              bottom: widget.direction != .down || split == null ? 0 : size,
            ),
          ),
          if (split != null && widget.resizable)
            KeyedSubtree(
              key: Key('handle'),
              child: memoizedHandle.positioned(
                left: widget.direction == .left ? size : null,
                right: widget.direction == .right ? size : null,
                top: widget.direction == .up ? size : null,
                bottom: widget.direction == .down ? size : null,
              ),
            ),
        ].toStack(alignment: .center);
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
      Axis.horizontal => inkWell.constrained(
        width: _handleSize.width,
        height: _handleSize.height,
      ),
      Axis.vertical => inkWell.constrained(
        height: _handleSize.width,
        width: _handleSize.height,
      ),
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

    return Ink(key: key, child: gestureDetector).material(
      color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(200),
      borderRadius: BorderRadius.all(Radius.circular(_handleSize.width)),
      clipBehavior: .hardEdge,
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
