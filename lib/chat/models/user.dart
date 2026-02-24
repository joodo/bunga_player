import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/client_info/global_business.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  late final int colorHue;

  User({required this.id, required this.name, int? colorHue}) {
    this.colorHue = colorHue ?? (id.hashCode % 360);
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  factory User.of(BuildContext context) {
    final nickname = context.read<ClientNicknameNotifier>().value;
    final hue = context.read<ClientColorHueNotifier?>()?.value;
    final id = context.read<ClientAccount>().id;
    return User(id: id, name: nickname, colorHue: hue);
  }

  bool isCurrent(BuildContext context) =>
      id == context.read<ClientAccount>().id;

  bool get isServer => id == 'server';

  /// Based on hsv.
  /// brightness 0.0 ~ 1.0, the higher, the lighter
  Color getColor({required double brightness}) {
    final hsvColor = HSVColor.fromAHSV(1, colorHue.toDouble(), 0.5, brightness);
    return hsvColor.toColor();
  }

  @override
  String toString() => toJson().toString();
}
