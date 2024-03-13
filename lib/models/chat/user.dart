import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  factory User.fromPref() {
    final pref = getIt<Preferences>();
    final name = pref.get<String>('user_name')!;
    String? clientId = pref.get<String>('client_id');
    if (clientId == null) {
      clientId = const Uuid().v4();
      pref.set('client_id', clientId);
    }
    return User(id: clientId, name: name);
  }

  /// Based on hsv.
  /// value 0.0 ~ 1.0, the higher, the lighter
  Color getColor(double value) {
    final hash = id.hashCode;
    final hsvColor = HSVColor.fromAHSV(1, (hash % 360), 0.5, value);
    return hsvColor.toColor();
  }

  @override
  String toString() => toJson().toString();

  @override
  operator ==(Object other) {
    if (other is User) {
      return other.id == id;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => id.hashCode;
}
