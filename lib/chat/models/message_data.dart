import 'package:json_annotation/json_annotation.dart';

import 'package:bunga_player/play/models/video_record.dart';

import 'user.dart';

part 'message_data.g.dart';

abstract class MessageData {
  String get code;
  Map<String, dynamic> toJson();
}

/// Send when sharing video
@JsonSerializable()
class StartProjectionMessageData extends MessageData {
  static const messageCode = 'start-projection';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final VideoRecord videoRecord;

  StartProjectionMessageData({required this.videoRecord});

  factory StartProjectionMessageData.fromJson(Map<String, dynamic> json) =>
      _$StartProjectionMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StartProjectionMessageDataToJson(this);
}

/// Send when asking what's playing
@JsonSerializable()
class WhatsOnMessageData extends MessageData {
  static const messageCode = 'whats-on';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  WhatsOnMessageData();

  factory WhatsOnMessageData.fromJson(Map<String, dynamic> json) =>
      _$WhatsOnMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WhatsOnMessageDataToJson(this);
}

/// Send when answering what's playing
@JsonSerializable()
class NowPlayingMessageData extends MessageData {
  static const messageCode = 'now-playing';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

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
  static const messageCode = 'aloha';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

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
  static const messageCode = 'here-is';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

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
  static const messageCode = 'bye';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

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
  static const messageCode = 'where';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  WhereMessageData();

  factory WhereMessageData.fromJson(Map<String, dynamic> json) =>
      _$WhereMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WhereMessageDataToJson(this);
}

/// Send when answering playing position
@JsonSerializable()
class PlayAtMessageData extends MessageData {
  static const messageCode = 'play-at';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final User sender;
  final Duration position;
  final bool isPlaying;

  PlayAtMessageData({
    required this.sender,
    required this.position,
    required this.isPlaying,
  });

  factory PlayAtMessageData.fromJson(Map<String, dynamic> json) =>
      _$PlayAtMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PlayAtMessageDataToJson(this);
}

/// Send popmoji
@JsonSerializable()
class PopmojiMessageData extends MessageData {
  static const messageCode = 'popmoji';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final User sender;
  final String popmojiCode;

  PopmojiMessageData({required this.sender, required this.popmojiCode});

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

  final User sender;
  final String message;

  DanmakuMessageData({required this.sender, required this.message});

  factory DanmakuMessageData.fromJson(Map<String, dynamic> json) =>
      _$DanmakuMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DanmakuMessageDataToJson(this);
}

/// Send when negotiating calling
enum CallAction { ask, yes, no, cancel }

@JsonSerializable()
class CallMessageData extends MessageData {
  static const messageCode = 'call';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

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
  static const messageCode = 'talk-status';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final TalkStatus status;

  TalkStatusMessageData({required this.status});

  factory TalkStatusMessageData.fromJson(Map<String, dynamic> json) =>
      _$TalkStatusMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TalkStatusMessageDataToJson(this);
}

/// Send when sharing subtitle
@JsonSerializable()
class ShareSubMessageData extends MessageData {
  static const messageCode = 'share-sub';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final String url;
  final User sharer;
  final String title;

  ShareSubMessageData({
    required this.url,
    required this.sharer,
    required this.title,
  });

  factory ShareSubMessageData.fromJson(Map<String, dynamic> json) =>
      _$ShareSubMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ShareSubMessageDataToJson(this);
}
