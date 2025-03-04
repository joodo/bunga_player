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

extension AlohaExtension on Map<String, dynamic> {
  bool get isAlohaData => this['type'] == 'aloha';
  AlohaMessageData toAlohaData() => isAlohaData
      ? AlohaMessageData(user: User.fromJson(this))
      : throw const FormatException();

  bool get isHereIsData => this['type'] == 'hereIs';
  HereIsMessageData toHereIsData() => isHereIsData
      ? HereIsMessageData(
          user: User.fromJson(this),
          isTalking: this['isTalking'],
        )
      : throw const FormatException();

  bool get isByeData => this['type'] == 'bye';
}
