import 'package:json_annotation/json_annotation.dart';

import 'package:bunga_player/play/models/video_record.dart';

import 'user.dart';

part 'message_data.g.dart';

@JsonSerializable()
class StartProjectionMessageData {
  final User sharer;
  final VideoRecord videoRecord;
  StartProjectionMessageData({
    required this.sharer,
    required this.videoRecord,
  });

  factory StartProjectionMessageData.fromJson(Map<String, dynamic> json) =>
      _$StartProjectionMessageDataFromJson(json);
  Map<String, dynamic> toJson() => _$StartProjectionMessageDataToJson(this);
}

class AlohaMessageData {
  final User user;

  AlohaMessageData({required this.user});

  Map<String, dynamic> toMessageData() => {'type': 'aloha', ...user.toJson()};
}

class HereIsMessageData {
  final User user;
  final bool isTalking;

  HereIsMessageData({required this.user, required this.isTalking});

  Map<String, dynamic> toMessageData() => {
        'type': 'hereIs',
        ...user.toJson(),
        'isTalking': isTalking,
      };
}

class ByeMessageData {
  Map<String, dynamic> toMessageData() => {'type': 'bye'};
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
