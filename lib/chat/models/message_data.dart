import 'package:json_annotation/json_annotation.dart';

import 'package:bunga_player/play/models/video_record.dart';

import 'user.dart';

part 'message_data.g.dart';

abstract class MessageData {
  String get type;
  Map<String, dynamic> toJson();
}

/// Send when sharing video
@JsonSerializable()
class StartProjectionMessageData extends MessageData {
  static const messageType = 'start-projection';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final User sharer;
  final VideoRecord videoRecord;

  StartProjectionMessageData({
    required this.sharer,
    required this.videoRecord,
  });

  factory StartProjectionMessageData.fromJson(Map<String, dynamic> json) =>
      _$StartProjectionMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StartProjectionMessageDataToJson(this);
}

/// Send when join watching
@JsonSerializable()
class AlohaMessageData extends MessageData {
  static const messageType = 'aloha';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final User user;

  AlohaMessageData({required this.user});

  factory AlohaMessageData.fromJson(Map<String, dynamic> json) =>
      _$AlohaMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AlohaMessageDataToJson(this);
}

/// Send when answering aloha
@JsonSerializable()
class HereIsMessageData extends MessageData {
  static const messageType = 'here-is';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final User user;
  final bool isTalking;

  HereIsMessageData({required this.user, required this.isTalking});

  factory HereIsMessageData.fromJson(Map<String, dynamic> json) =>
      _$HereIsMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$HereIsMessageDataToJson(this);
}

/// Send when leave watching
@JsonSerializable()
class ByeMessageData extends MessageData {
  static const messageType = 'bye';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final String userId;

  ByeMessageData({required this.userId});

  factory ByeMessageData.fromJson(Map<String, dynamic> json) =>
      _$ByeMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ByeMessageDataToJson(this);
}

/// Send when asking playing position
@JsonSerializable()
class WhereMessageData extends MessageData {
  static const messageType = 'where';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  WhereMessageData();

  factory WhereMessageData.fromJson(Map<String, dynamic> json) =>
      _$WhereMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WhereMessageDataToJson(this);
}

/// Send when answering playing position
@JsonSerializable()
class PlayAtMessageData extends MessageData {
  static const messageType = 'play-at';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final Duration position;
  final bool isPlaying;

  PlayAtMessageData({required this.position, required this.isPlaying});

  factory PlayAtMessageData.fromJson(Map<String, dynamic> json) =>
      _$PlayAtMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PlayAtMessageDataToJson(this);
}
