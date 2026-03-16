import 'package:json_annotation/json_annotation.dart';

import 'package:bunga_player/chat/models/message_data.dart';

part 'message_data.g.dart';

/// Send status as heartbeat
@JsonSerializable()
class ClientStatusMessageData extends MessageData {
  static const messageCode = 'client-status';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final bool isPending;

  ClientStatusMessageData(this.isPending);

  factory ClientStatusMessageData.fromJson(Map<String, dynamic> json) =>
      _$ClientStatusMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ClientStatusMessageDataToJson(this);
}

/// Receive channel status as heartbeat

enum ChannelPlayStatus {
  paused,
  pending,
  playing;

  bool get isPlaying => this == playing;
}

@JsonSerializable()
class ChannelStatusMessageData extends MessageData {
  static const messageCode = 'channel-status';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final List<String> watcherIds;
  final List<String> readyIds;
  final Duration position;
  final ChannelPlayStatus playStatus;

  ChannelStatusMessageData({
    required this.watcherIds,
    required this.readyIds,
    required this.position,
    required this.playStatus,
  });

  factory ChannelStatusMessageData.fromJson(Map<String, dynamic> json) =>
      _$ChannelStatusMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ChannelStatusMessageDataToJson(this);
}

/// Send/Receive when start play
@JsonSerializable()
class PlayMessageData extends MessageData {
  static const messageCode = 'play';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  PlayMessageData();

  factory PlayMessageData.fromJson(Map<String, dynamic> json) =>
      _$PlayMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PlayMessageDataToJson(this);
}

/// Send/Receive when pause
@JsonSerializable()
class PauseMessageData extends MessageData {
  static const messageCode = 'pause';
  @override
  @JsonKey(includeFromJson: false, includeToJson: true)
  final code = messageCode;

  final Duration position;

  PauseMessageData({required this.position});

  factory PauseMessageData.fromJson(Map<String, dynamic> json) =>
      _$PauseMessageDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PauseMessageDataToJson(this);
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
