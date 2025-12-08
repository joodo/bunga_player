import 'package:json_annotation/json_annotation.dart';

import 'package:bunga_player/play/models/video_record.dart';

import 'user.dart';

part 'message_data.g.dart';

abstract class MessageData {
  String get code;
  Map<String, dynamic> toJson();
}

/// Receive when reconnected to chat server
@JsonSerializable()
class WhoAreYouMessageData extends MessageData {
  static const messageCode = 'who-are-you';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  WhoAreYouMessageData();

  factory WhoAreYouMessageData.fromJson(Map<String, dynamic> json) =>
      _$WhoAreYouMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WhoAreYouMessageDataToJson(this);
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

/// Receive when answering what's playing
@JsonSerializable()
class NowPlayingMessageData extends MessageData {
  static const messageCode = 'now-playing';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final VideoRecord videoRecord;

  NowPlayingMessageData({required this.videoRecord});

  factory NowPlayingMessageData.fromJson(Map<String, dynamic> json) =>
      _$NowPlayingMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NowPlayingMessageDataToJson(this);
}

/// Send when join watching
@JsonSerializable()
class JoinInMessageData extends MessageData {
  static const messageCode = 'join-in';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final User user;
  final VideoRecord? myShare;

  JoinInMessageData({required this.user, this.myShare});

  factory JoinInMessageData.fromJson(Map<String, dynamic> json) =>
      _$JoinInMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$JoinInMessageDataToJson(this);
}

/// Receive when answering aloha
@JsonSerializable()
class WatcherInfo {
  final User user;
  final SyncStatus syncStatus;

  WatcherInfo({required this.user, required this.syncStatus});

  factory WatcherInfo.fromJson(Map<String, dynamic> json) =>
      _$WatcherInfoFromJson(json);
  Map<String, dynamic> toJson() => _$WatcherInfoToJson(this);
}

/// Receive when join in room
@JsonSerializable()
class HereAreMessageData extends MessageData {
  static const messageCode = 'here-are';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final List<WatcherInfo> watchers;

  HereAreMessageData({required this.watchers});

  factory HereAreMessageData.fromJson(Map<String, dynamic> json) =>
      _$HereAreMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$HereAreMessageDataToJson(this);
}

/// Send/receive when sharing video
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

/// Send/receive when sync status changed
enum SyncStatus { buffering, ready, detached }

@JsonSerializable()
class SyncStatusMessageData extends MessageData {
  static const messageCode = 'sync-status';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final SyncStatus status;

  SyncStatusMessageData(this.status);

  factory SyncStatusMessageData.fromJson(Map<String, dynamic> json) =>
      _$SyncStatusMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SyncStatusMessageDataToJson(this);
}

/// Send when join watching
@JsonSerializable()
class AlohaMessageData extends MessageData {
  static const messageCode = 'aloha';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  AlohaMessageData();

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

  ByeMessageData();

  factory ByeMessageData.fromJson(Map<String, dynamic> json) =>
      _$ByeMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ByeMessageDataToJson(this);
}

/// Send when change play status
/// Receive when some change status
@JsonSerializable()
class PlayAtMessageData extends MessageData {
  static const messageCode = 'play-at';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final Duration position;
  final bool isPlay;

  PlayAtMessageData({required this.position, required this.isPlay});

  factory PlayAtMessageData.fromJson(Map<String, dynamic> json) =>
      _$PlayAtMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PlayAtMessageDataToJson(this);
}

/*
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
*/

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
