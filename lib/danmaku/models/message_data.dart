import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:bunga_player/chat/models/message_data.dart';

part 'message_data.g.dart';

/// Send popmoji
@JsonSerializable()
class PopmojiMessageData extends MessageData {
  static const messageCode = 'popmoji';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final String popmojiCode;

  PopmojiMessageData({required this.popmojiCode});

  factory PopmojiMessageData.fromJson(Map<String, dynamic> json) =>
      _$PopmojiMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PopmojiMessageDataToJson(this);
}

/// Send danmaku
@JsonSerializable()
class DanmakuMessageData extends MessageData {
  static const messageCode = 'danmaku';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final String message;

  DanmakuMessageData({required this.message});

  factory DanmakuMessageData.fromJson(Map<String, dynamic> json) =>
      _$DanmakuMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DanmakuMessageDataToJson(this);
}

/// Sparking
@JsonSerializable()
class SparkMessageData extends MessageData {
  static const messageCode = 'spark';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final String emoji;
  @JsonKey(fromJson: _fractionalOffsetFromJson, toJson: _fractionalOffsetToJson)
  final FractionalOffset fraction;

  SparkMessageData({required this.emoji, required this.fraction});

  static FractionalOffset _fractionalOffsetFromJson(List<dynamic> json) =>
      FractionalOffset(json[0], json[1]);
  static List<double> _fractionalOffsetToJson(FractionalOffset offset) => [
    offset.dx,
    offset.dy,
  ];

  factory SparkMessageData.fromJson(Map<String, dynamic> json) =>
      _$SparkMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SparkMessageDataToJson(this);
}
