// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartProjectionMessageData _$StartProjectionMessageDataFromJson(
        Map<String, dynamic> json) =>
    StartProjectionMessageData(
      sharer: User.fromJson(json['sharer'] as Map<String, dynamic>),
      videoRecord:
          VideoRecord.fromJson(json['video_record'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StartProjectionMessageDataToJson(
        StartProjectionMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'sharer': instance.sharer.toJson(),
      'video_record': instance.videoRecord.toJson(),
    };

AlohaMessageData _$AlohaMessageDataFromJson(Map<String, dynamic> json) =>
    AlohaMessageData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AlohaMessageDataToJson(AlohaMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'user': instance.user.toJson(),
    };

HereIsMessageData _$HereIsMessageDataFromJson(Map<String, dynamic> json) =>
    HereIsMessageData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      isTalking: json['is_talking'] as bool,
    );

Map<String, dynamic> _$HereIsMessageDataToJson(HereIsMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'user': instance.user.toJson(),
      'is_talking': instance.isTalking,
    };

ByeMessageData _$ByeMessageDataFromJson(Map<String, dynamic> json) =>
    ByeMessageData(
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$ByeMessageDataToJson(ByeMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'user_id': instance.userId,
    };

WhereMessageData _$WhereMessageDataFromJson(Map<String, dynamic> json) =>
    WhereMessageData();

Map<String, dynamic> _$WhereMessageDataToJson(WhereMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
    };

PlayAtMessageData _$PlayAtMessageDataFromJson(Map<String, dynamic> json) =>
    PlayAtMessageData(
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      position: Duration(microseconds: (json['position'] as num).toInt()),
      isPlaying: json['is_playing'] as bool,
      when: DateTime.parse(json['when'] as String),
    );

Map<String, dynamic> _$PlayAtMessageDataToJson(PlayAtMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'sender': instance.sender.toJson(),
      'position': instance.position.inMicroseconds,
      'is_playing': instance.isPlaying,
      'when': instance.when.toIso8601String(),
    };
