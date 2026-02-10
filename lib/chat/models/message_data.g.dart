// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhoAreYouMessageData _$WhoAreYouMessageDataFromJson(
  Map<String, dynamic> json,
) => WhoAreYouMessageData();

Map<String, dynamic> _$WhoAreYouMessageDataToJson(
  WhoAreYouMessageData instance,
) => <String, dynamic>{'code': instance.code};

WhatsOnMessageData _$WhatsOnMessageDataFromJson(Map<String, dynamic> json) =>
    WhatsOnMessageData();

Map<String, dynamic> _$WhatsOnMessageDataToJson(WhatsOnMessageData instance) =>
    <String, dynamic>{'code': instance.code};

NowPlayingMessageData _$NowPlayingMessageDataFromJson(
  Map<String, dynamic> json,
) => NowPlayingMessageData(
  record: VideoRecord.fromJson(json['record'] as Map<String, dynamic>),
  sharer: User.fromJson(json['sharer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NowPlayingMessageDataToJson(
  NowPlayingMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'record': instance.record.toJson(),
  'sharer': instance.sharer.toJson(),
};

JoinInMessageData _$JoinInMessageDataFromJson(Map<String, dynamic> json) =>
    JoinInMessageData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      myShare: json['my_share'] == null
          ? null
          : StartProjectionMessageData.fromJson(
              json['my_share'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$JoinInMessageDataToJson(JoinInMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'user': instance.user.toJson(),
      'my_share': instance.myShare?.toJson(),
    };

HereAreMessageData _$HereAreMessageDataFromJson(Map<String, dynamic> json) =>
    HereAreMessageData(
      watchers: (json['watchers'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      buffering: (json['buffering'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$HereAreMessageDataToJson(HereAreMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'watchers': instance.watchers.map((e) => e.toJson()).toList(),
      'buffering': instance.buffering,
    };

StartProjectionMessageData _$StartProjectionMessageDataFromJson(
  Map<String, dynamic> json,
) => StartProjectionMessageData(
  videoRecord: VideoRecord.fromJson(
    json['video_record'] as Map<String, dynamic>,
  ),
  position: json['position'] == null
      ? Duration.zero
      : Duration(microseconds: (json['position'] as num).toInt()),
);

Map<String, dynamic> _$StartProjectionMessageDataToJson(
  StartProjectionMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'video_record': instance.videoRecord.toJson(),
  'position': instance.position.inMicroseconds,
};

BufferStateChangedMessageData _$BufferStateChangedMessageDataFromJson(
  Map<String, dynamic> json,
) => BufferStateChangedMessageData(json['is_buffering'] as bool);

Map<String, dynamic> _$BufferStateChangedMessageDataToJson(
  BufferStateChangedMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'is_buffering': instance.isBuffering,
};

AlohaMessageData _$AlohaMessageDataFromJson(Map<String, dynamic> json) =>
    AlohaMessageData();

Map<String, dynamic> _$AlohaMessageDataToJson(AlohaMessageData instance) =>
    <String, dynamic>{'code': instance.code};

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
    ByeMessageData();

Map<String, dynamic> _$ByeMessageDataToJson(ByeMessageData instance) =>
    <String, dynamic>{'code': instance.code};

SetPlaybackMessageData _$SetPlaybackMessageDataFromJson(
  Map<String, dynamic> json,
) => SetPlaybackMessageData(isPlay: json['is_play'] as bool);

Map<String, dynamic> _$SetPlaybackMessageDataToJson(
  SetPlaybackMessageData instance,
) => <String, dynamic>{'code': instance.code, 'is_play': instance.isPlay};

SeekMessageData _$SeekMessageDataFromJson(Map<String, dynamic> json) =>
    SeekMessageData(
      position: Duration(microseconds: (json['position'] as num).toInt()),
    );

Map<String, dynamic> _$SeekMessageDataToJson(SeekMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'position': instance.position.inMicroseconds,
    };

PlayFinishedMessageData _$PlayFinishedMessageDataFromJson(
  Map<String, dynamic> json,
) => PlayFinishedMessageData();

Map<String, dynamic> _$PlayFinishedMessageDataToJson(
  PlayFinishedMessageData instance,
) => <String, dynamic>{'code': instance.code};

PlayAtMessageData _$PlayAtMessageDataFromJson(Map<String, dynamic> json) =>
    PlayAtMessageData(
      position: Duration(microseconds: (json['position'] as num).toInt()),
      isPlay: json['is_play'] as bool,
    );

Map<String, dynamic> _$PlayAtMessageDataToJson(PlayAtMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'position': instance.position.inMicroseconds,
      'is_play': instance.isPlay,
    };

PopmojiMessageData _$PopmojiMessageDataFromJson(Map<String, dynamic> json) =>
    PopmojiMessageData(popmojiCode: json['popmoji_code'] as String);

Map<String, dynamic> _$PopmojiMessageDataToJson(PopmojiMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'popmoji_code': instance.popmojiCode,
    };

DanmakuMessageData _$DanmakuMessageDataFromJson(Map<String, dynamic> json) =>
    DanmakuMessageData(message: json['message'] as String);

Map<String, dynamic> _$DanmakuMessageDataToJson(DanmakuMessageData instance) =>
    <String, dynamic>{'code': instance.code, 'message': instance.message};

ShareSubMessageData _$ShareSubMessageDataFromJson(Map<String, dynamic> json) =>
    ShareSubMessageData(
      url: json['url'] as String,
      title: json['title'] as String,
    );

Map<String, dynamic> _$ShareSubMessageDataToJson(
  ShareSubMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'url': instance.url,
  'title': instance.title,
};
