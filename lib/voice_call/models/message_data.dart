import 'package:json_annotation/json_annotation.dart';

import 'package:bunga_player/chat/models/message_data.dart';

part 'message_data.g.dart';

/// Send when negotiating calling
enum CallAction { call, accept, reject, cancel }

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
