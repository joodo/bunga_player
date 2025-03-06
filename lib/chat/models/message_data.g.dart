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

WhatsOnMessageData _$WhatsOnMessageDataFromJson(Map<String, dynamic> json) =>
    WhatsOnMessageData();

Map<String, dynamic> _$WhatsOnMessageDataToJson(WhatsOnMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
    };

NowPlayingMessageData _$NowPlayingMessageDataFromJson(
        Map<String, dynamic> json) =>
    NowPlayingMessageData(
      videoRecord:
          VideoRecord.fromJson(json['video_record'] as Map<String, dynamic>),
      sharer: User.fromJson(json['sharer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NowPlayingMessageDataToJson(
        NowPlayingMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'video_record': instance.videoRecord.toJson(),
      'sharer': instance.sharer.toJson(),
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

PopmojiMessageData _$PopmojiMessageDataFromJson(Map<String, dynamic> json) =>
    PopmojiMessageData(
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      code: json['code'] as String,
    );

Map<String, dynamic> _$PopmojiMessageDataToJson(PopmojiMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'sender': instance.sender.toJson(),
      'code': instance.code,
    };

DanmakuMessageData _$DanmakuMessageDataFromJson(Map<String, dynamic> json) =>
    DanmakuMessageData(
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      message: json['message'] as String,
    );

Map<String, dynamic> _$DanmakuMessageDataToJson(DanmakuMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'sender': instance.sender.toJson(),
      'message': instance.message,
    };

CallMessageData _$CallMessageDataFromJson(Map<String, dynamic> json) =>
    CallMessageData(
      action: $enumDecode(_$CallActionEnumMap, json['action']),
    );

Map<String, dynamic> _$CallMessageDataToJson(CallMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'action': _$CallActionEnumMap[instance.action]!,
    };

const _$CallActionEnumMap = {
  CallAction.ask: 'ask',
  CallAction.yes: 'yes',
  CallAction.no: 'no',
  CallAction.cancel: 'cancel',
};

TalkStatusMessageData _$TalkStatusMessageDataFromJson(
        Map<String, dynamic> json) =>
    TalkStatusMessageData(
      status: $enumDecode(_$TalkStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$TalkStatusMessageDataToJson(
        TalkStatusMessageData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'status': _$TalkStatusEnumMap[instance.status]!,
    };

const _$TalkStatusEnumMap = {
  TalkStatus.start: 'start',
  TalkStatus.end: 'end',
};
