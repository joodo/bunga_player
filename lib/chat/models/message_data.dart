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

/// Send when asking what's playing
@JsonSerializable()
class WhatsOnMessageData extends MessageData {
  static const messageType = 'whats-on';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  WhatsOnMessageData();

  factory WhatsOnMessageData.fromJson(Map<String, dynamic> json) =>
      _$WhatsOnMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WhatsOnMessageDataToJson(this);
}

/// Send when answering what's playing
@JsonSerializable()
class NowPlayingMessageData extends MessageData {
  static const messageType = 'now-playing';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final VideoRecord videoRecord;
  final User sharer;

  NowPlayingMessageData({required this.videoRecord, required this.sharer});

  factory NowPlayingMessageData.fromJson(Map<String, dynamic> json) =>
      _$NowPlayingMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NowPlayingMessageDataToJson(this);
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

  final User sender;
  final Duration position;
  final bool isPlaying;
  final DateTime when;

  PlayAtMessageData({
    required this.sender,
    required this.position,
    required this.isPlaying,
    required this.when,
  });

  factory PlayAtMessageData.fromJson(Map<String, dynamic> json) =>
      _$PlayAtMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PlayAtMessageDataToJson(this);
}

/// Send popmoji
@JsonSerializable()
class PopmojiMessageData extends MessageData {
  static const messageType = 'popmoji';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final User sender;
  final String code;

  PopmojiMessageData({
    required this.sender,
    required this.code,
  });

  factory PopmojiMessageData.fromJson(Map<String, dynamic> json) =>
      _$PopmojiMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PopmojiMessageDataToJson(this);
}

/// Send danmaku
@JsonSerializable()
class DanmakuMessageData extends MessageData {
  static const messageType = 'danmaku';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final User sender;
  final String message;

  DanmakuMessageData({
    required this.sender,
    required this.message,
  });

  factory DanmakuMessageData.fromJson(Map<String, dynamic> json) =>
      _$DanmakuMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DanmakuMessageDataToJson(this);
}

/// Send when negotiating calling
enum CallAction { ask, yes, no, cancel }

@JsonSerializable()
class CallMessageData extends MessageData {
  static const messageType = 'call';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final CallAction action;

  CallMessageData({required this.action});

  factory CallMessageData.fromJson(Map<String, dynamic> json) =>
      _$CallMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CallMessageDataToJson(this);
}

/// Send when join / leave talking
enum TalkStatus { start, end }

@JsonSerializable()
class TalkStatusMessageData extends MessageData {
  static const messageType = 'talk-status';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final type = messageType;

  final TalkStatus status;

  TalkStatusMessageData({required this.status});

  factory TalkStatusMessageData.fromJson(Map<String, dynamic> json) =>
      _$TalkStatusMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TalkStatusMessageDataToJson(this);
}
