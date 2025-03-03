// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WatchProgressImpl _$$WatchProgressImplFromJson(Map<String, dynamic> json) =>
    _$WatchProgressImpl(
      position: Duration(microseconds: (json['position'] as num).toInt()),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
    );

Map<String, dynamic> _$$WatchProgressImplToJson(_$WatchProgressImpl instance) =>
    <String, dynamic>{
      'position': instance.position.inMicroseconds,
      'duration': instance.duration.inMicroseconds,
    };

_$VideoSessionImpl _$$VideoSessionImplFromJson(Map<String, dynamic> json) =>
    _$VideoSessionImpl(
      updatedAt: DateTime.parse(json['updated_at'] as String),
      videoRecord:
          VideoRecord.fromJson(json['video_record'] as Map<String, dynamic>),
      progress:
          WatchProgress.fromJson(json['progress'] as Map<String, dynamic>),
      subtitleUri: json['subtitle_uri'] as String?,
    );

Map<String, dynamic> _$$VideoSessionImplToJson(_$VideoSessionImpl instance) =>
    <String, dynamic>{
      'updated_at': instance.updatedAt.toIso8601String(),
      'video_record': instance.videoRecord.toJson(),
      'progress': instance.progress.toJson(),
      'subtitle_uri': instance.subtitleUri,
    };

_$HistoryImpl _$$HistoryImplFromJson(Map<String, dynamic> json) =>
    _$HistoryImpl(
      value: (json['value'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, VideoSession.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$HistoryImplToJson(_$HistoryImpl instance) =>
    <String, dynamic>{
      'value': instance.value.map((k, e) => MapEntry(k, e.toJson())),
    };
