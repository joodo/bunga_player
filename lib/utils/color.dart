import 'package:bunga_player/models/chat/user.dart';
import 'package:flutter/painting.dart';

extension UserColor on User {
  /// Based on hsv.
  /// value 0.0 ~ 1.0, the higher, the lighter
  Color getColor(double value) {
    final hash = id.hashCode;
    final hsvColor = HSVColor.fromAHSV(1, (hash % 360), 0.5, value);
    return hsvColor.toColor();
  }
}
