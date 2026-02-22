import 'package:json_annotation/json_annotation.dart';

import 'package:bunga_player/chat/models/message_data.dart';

part 'message_data.g.dart';

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

/// Send when video finished
@JsonSerializable()
class PlayFinishedMessageData extends MessageData {
  static const messageCode = 'play-finished';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  PlayFinishedMessageData();

  factory PlayFinishedMessageData.fromJson(Map<String, dynamic> json) =>
      _$PlayFinishedMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PlayFinishedMessageDataToJson(this);
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
