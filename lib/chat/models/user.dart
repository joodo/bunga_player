import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

extension UserId on List<User> {
  bool containsId(String id) {
    return any((user) => user.id == id);
  }

  void removeId(String id) {
    removeWhere((user) => user.id == id);
  }
}

@JsonSerializable()
class User {
  final String id;
  final String name;
  late final int colorHue;

  User({
    required this.id,
    required this.name,
    int? colorHue,
  }) {
    this.colorHue = colorHue ?? (id.hashCode % 360);
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Based on hsv.
  /// value 0.0 ~ 1.0, the higher, the lighter
  Color getColor(double value) {
    final hsvColor = HSVColor.fromAHSV(1, colorHue.toDouble(), 0.5, value);
    return hsvColor.toColor();
  }

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(other) {
    return other is User &&
        id == other.id &&
        name == other.name &&
        colorHue == other.colorHue;
  }

  @override
  int get hashCode => Object.hash(id, name, colorHue);
}
