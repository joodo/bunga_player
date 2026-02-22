// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BufferStateChangedMessageData _$BufferStateChangedMessageDataFromJson(
  Map<String, dynamic> json,
) => BufferStateChangedMessageData(json['is_buffering'] as bool);

Map<String, dynamic> _$BufferStateChangedMessageDataToJson(
  BufferStateChangedMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'is_buffering': instance.isBuffering,
};

PlayMessageData _$PlayMessageDataFromJson(Map<String, dynamic> json) =>
    PlayMessageData();

Map<String, dynamic> _$PlayMessageDataToJson(PlayMessageData instance) =>
    <String, dynamic>{'code': instance.code};

PauseMessageData _$PauseMessageDataFromJson(Map<String, dynamic> json) =>
    PauseMessageData(
      position: Duration(microseconds: (json['position'] as num).toInt()),
    );

Map<String, dynamic> _$PauseMessageDataToJson(PauseMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'position': instance.position.inMicroseconds,
    };

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
