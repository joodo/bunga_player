// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StartProjectionMessageData _$StartProjectionMessageDataFromJson(
  Map<String, dynamic> json,
) => StartProjectionMessageData(
  videoRecord: VideoRecord.fromJson(
    json['video_record'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$StartProjectionMessageDataToJson(
  StartProjectionMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'video_record': instance.videoRecord.toJson(),
};

WhatsOnMessageData _$WhatsOnMessageDataFromJson(Map<String, dynamic> json) =>
    WhatsOnMessageData();

Map<String, dynamic> _$WhatsOnMessageDataToJson(WhatsOnMessageData instance) =>
    <String, dynamic>{'code': instance.code};

NowPlayingMessageData _$NowPlayingMessageDataFromJson(
  Map<String, dynamic> json,
) => NowPlayingMessageData(
  videoRecord: VideoRecord.fromJson(
    json['video_record'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$NowPlayingMessageDataToJson(
  NowPlayingMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'video_record': instance.videoRecord.toJson(),
};

JoinInMessageData _$JoinInMessageDataFromJson(Map<String, dynamic> json) =>
    JoinInMessageData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      myShare: json['my_share'] == null
          ? null
          : VideoRecord.fromJson(json['my_share'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JoinInMessageDataToJson(JoinInMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'user': instance.user.toJson(),
      'my_share': instance.myShare?.toJson(),
    };

AlohaMessageData _$AlohaMessageDataFromJson(Map<String, dynamic> json) =>
    AlohaMessageData(user: User.fromJson(json['user'] as Map<String, dynamic>));

Map<String, dynamic> _$AlohaMessageDataToJson(AlohaMessageData instance) =>
    <String, dynamic>{'code': instance.code, 'user': instance.user.toJson()};

HereIsMessageData _$HereIsMessageDataFromJson(Map<String, dynamic> json) =>
    HereIsMessageData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      isTalking: json['is_talking'] as bool,
    );

Map<String, dynamic> _$HereIsMessageDataToJson(HereIsMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'user': instance.user.toJson(),
      'is_talking': instance.isTalking,
    };

ByeMessageData _$ByeMessageDataFromJson(Map<String, dynamic> json) =>
    ByeMessageData(userId: json['user_id'] as String);

Map<String, dynamic> _$ByeMessageDataToJson(ByeMessageData instance) =>
    <String, dynamic>{'code': instance.code, 'user_id': instance.userId};

WhereMessageData _$WhereMessageDataFromJson(Map<String, dynamic> json) =>
    WhereMessageData();

Map<String, dynamic> _$WhereMessageDataToJson(WhereMessageData instance) =>
    <String, dynamic>{'code': instance.code};

PlayAtMessageData _$PlayAtMessageDataFromJson(Map<String, dynamic> json) =>
    PlayAtMessageData(
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      position: Duration(microseconds: (json['position'] as num).toInt()),
      isPlaying: json['is_playing'] as bool,
    );

Map<String, dynamic> _$PlayAtMessageDataToJson(PlayAtMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'sender': instance.sender.toJson(),
      'position': instance.position.inMicroseconds,
      'is_playing': instance.isPlaying,
    };

PopmojiMessageData _$PopmojiMessageDataFromJson(Map<String, dynamic> json) =>
    PopmojiMessageData(
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      popmojiCode: json['popmoji_code'] as String,
    );

Map<String, dynamic> _$PopmojiMessageDataToJson(PopmojiMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'sender': instance.sender.toJson(),
      'popmoji_code': instance.popmojiCode,
    };

DanmakuMessageData _$DanmakuMessageDataFromJson(Map<String, dynamic> json) =>
    DanmakuMessageData(
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      message: json['message'] as String,
    );

Map<String, dynamic> _$DanmakuMessageDataToJson(DanmakuMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'sender': instance.sender.toJson(),
      'message': instance.message,
    };

CallMessageData _$CallMessageDataFromJson(Map<String, dynamic> json) =>
    CallMessageData(action: $enumDecode(_$CallActionEnumMap, json['action']));

Map<String, dynamic> _$CallMessageDataToJson(CallMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'action': _$CallActionEnumMap[instance.action]!,
    };

const _$CallActionEnumMap = {
  CallAction.ask: 'ask',
  CallAction.yes: 'yes',
  CallAction.no: 'no',
  CallAction.cancel: 'cancel',
};

TalkStatusMessageData _$TalkStatusMessageDataFromJson(
  Map<String, dynamic> json,
) => TalkStatusMessageData(
  status: $enumDecode(_$TalkStatusEnumMap, json['status']),
);

Map<String, dynamic> _$TalkStatusMessageDataToJson(
  TalkStatusMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'status': _$TalkStatusEnumMap[instance.status]!,
};

const _$TalkStatusEnumMap = {TalkStatus.start: 'start', TalkStatus.end: 'end'};

ShareSubMessageData _$ShareSubMessageDataFromJson(Map<String, dynamic> json) =>
    ShareSubMessageData(
      url: json['url'] as String,
      sharer: User.fromJson(json['sharer'] as Map<String, dynamic>),
      title: json['title'] as String,
    );

Map<String, dynamic> _$ShareSubMessageDataToJson(
  ShareSubMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'url': instance.url,
  'sharer': instance.sharer.toJson(),
  'title': instance.title,
};
