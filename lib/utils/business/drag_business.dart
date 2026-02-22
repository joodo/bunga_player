import 'package:flutter/widgets.dart';

class DragBusiness<T> {
  final Offset startPosition;
  final Axis orientation;
  final T startValue;
  final dynamic Function(T startValue, double distance) onUpdate;

  DragBusiness({
    required this.startPosition,
    required this.orientation,
    required this.startValue,
    required this.onUpdate,
  });

  dynamic updatePosition(Offset currentPosition) {
    final distance = switch (orientation) {
      Axis.horizontal => currentPosition.dx - startPosition.dx,
      Axis.vertical => startPosition.dy - currentPosition.dy,
    };
    return onUpdate(startValue, distance);
  }
}
