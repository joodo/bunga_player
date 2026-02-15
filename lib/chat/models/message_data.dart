import 'package:json_annotation/json_annotation.dart';

import 'package:bunga_player/play/models/video_record.dart';

import 'user.dart';

part 'message_data.g.dart';

abstract class MessageData {
  String get code;
  Map<String, dynamic> toJson();
}

// TODO:split

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

  final VideoRecord record;
  final User sharer;

  NowPlayingMessageData({required this.record, required this.sharer});

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
  final StartProjectionMessageData? myShare;

  JoinInMessageData({required this.user, this.myShare});

  factory JoinInMessageData.fromJson(Map<String, dynamic> json) =>
      _$JoinInMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$JoinInMessageDataToJson(this);
}

/// Receive when join in room
@JsonSerializable()
class HereAreMessageData extends MessageData {
  static const messageCode = 'here-are';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final List<User> watchers;
  final List<String> buffering;

  HereAreMessageData({required this.watchers, required this.buffering});

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
  final Duration position;

  StartProjectionMessageData({
    required this.videoRecord,
    this.position = Duration.zero,
  });

  factory StartProjectionMessageData.fromJson(Map<String, dynamic> json) =>
      _$StartProjectionMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StartProjectionMessageDataToJson(this);
}

/// Receive when server reset cache
@JsonSerializable()
class ResetMessageData extends MessageData {
  static const messageCode = 'reset';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  ResetMessageData();

  factory ResetMessageData.fromJson(Map<String, dynamic> json) =>
      _$ResetMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ResetMessageDataToJson(this);
}

/// Send/receive when buffer status changed
@JsonSerializable()
class BufferStateChangedMessageData extends MessageData {
  static const messageCode = 'buffer-state-changed';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final bool isBuffering;

  BufferStateChangedMessageData(this.isBuffering);

  factory BufferStateChangedMessageData.fromJson(Map<String, dynamic> json) =>
      _$BufferStateChangedMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BufferStateChangedMessageDataToJson(this);
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

/// Send when toggle playback
@JsonSerializable()
class SetPlaybackMessageData extends MessageData {
  static const messageCode = 'set-playback';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final bool isPlay;

  SetPlaybackMessageData({required this.isPlay});

  factory SetPlaybackMessageData.fromJson(Map<String, dynamic> json) =>
      _$SetPlaybackMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SetPlaybackMessageDataToJson(this);
}

/// Send when seek video
@JsonSerializable()
class SeekMessageData extends MessageData {
  static const messageCode = 'seek';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final Duration position;

  SeekMessageData({required this.position});

  factory SeekMessageData.fromJson(Map<String, dynamic> json) =>
      _$SeekMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SeekMessageDataToJson(this);
}

/// Receive when someone change play status
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

/// Send when sharing subtitle
@JsonSerializable()
class ShareSubMessageData extends MessageData {
  static const messageCode = 'share-sub';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final String url;
  final String title;

  ShareSubMessageData({required this.url, required this.title});

  factory ShareSubMessageData.fromJson(Map<String, dynamic> json) =>
      _$ShareSubMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ShareSubMessageDataToJson(this);
}
