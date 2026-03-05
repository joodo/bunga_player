import 'package:flutter/widgets.dart';

class DragBusiness<T> {
  final Offset startPosition;
  final Axis orientation;
  final T startValue;
  final dynamic Function(T startValue, double distance) onUpdate;
  final dynamic Function(T startValue, double distance)? onEnd;

  DragBusiness({
    required this.startPosition,
    required this.orientation,
    required this.startValue,
    required this.onUpdate,
    this.onEnd,
  });

  dynamic updatePosition(Offset currentPosition) {
    final distance = switch (orientation) {
      Axis.horizontal => currentPosition.dx - startPosition.dx,
      Axis.vertical => startPosition.dy - currentPosition.dy,
    };
    return onUpdate(startValue, distance);
  }

  dynamic end(Offset finalPosition) {
    final distance = switch (orientation) {
      Axis.horizontal => finalPosition.dx - startPosition.dx,
      Axis.vertical => startPosition.dy - finalPosition.dy,
    };
    return onEnd?.call(startValue, distance);
  }

  dynamic cancel() => onUpdate(startValue, 0);
}
