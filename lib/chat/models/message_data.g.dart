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

ResetMessageData _$ResetMessageDataFromJson(Map<String, dynamic> json) =>
    ResetMessageData();

Map<String, dynamic> _$ResetMessageDataToJson(ResetMessageData instance) =>
    <String, dynamic>{'code': instance.code};

AlohaMessageData _$AlohaMessageDataFromJson(Map<String, dynamic> json) =>
    AlohaMessageData();

Map<String, dynamic> _$AlohaMessageDataToJson(AlohaMessageData instance) =>
    <String, dynamic>{'code': instance.code};

ByeMessageData _$ByeMessageDataFromJson(Map<String, dynamic> json) =>
    ByeMessageData();

Map<String, dynamic> _$ByeMessageDataToJson(ByeMessageData instance) =>
    <String, dynamic>{'code': instance.code};
