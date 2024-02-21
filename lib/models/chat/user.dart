import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Based on hsv.
  /// value 0.0 ~ 1.0, the higher, the lighter
  Color getColor(double value) {
    final hash = id.hashCode;
    final hsvColor = HSVColor.fromAHSV(1, (hash % 360), 0.5, value);
    return hsvColor.toColor();
  }

  @override
  String toString() => toJson().toString();
}
