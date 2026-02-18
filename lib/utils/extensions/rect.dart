import 'package:flutter/material.dart';

extension RectGeometryExtensions on Rect {
  FractionalOffset toFractionalOffset(Offset localPosition) {
    return FractionalOffset(
      ((localPosition.dx - left) / width).clamp(0.0, 1.0),
      ((localPosition.dy - top) / height).clamp(0.0, 1.0),
    );
  }
}
