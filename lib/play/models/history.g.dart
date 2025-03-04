// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WatchProgress _$WatchProgressFromJson(Map<String, dynamic> json) =>
    _WatchProgress(
      position: Duration(microseconds: (json['position'] as num).toInt()),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
    );

Map<String, dynamic> _$WatchProgressToJson(_WatchProgress instance) =>
    <String, dynamic>{
      'position': instance.position.inMicroseconds,
      'duration': instance.duration.inMicroseconds,
    };

_VideoSession _$VideoSessionFromJson(Map<String, dynamic> json) =>
    _VideoSession(
      updatedAt: DateTime.parse(json['updated_at'] as String),
      videoRecord:
          VideoRecord.fromJson(json['video_record'] as Map<String, dynamic>),
      progress:
          WatchProgress.fromJson(json['progress'] as Map<String, dynamic>),
      subtitleUri: json['subtitle_uri'] as String?,
    );

Map<String, dynamic> _$VideoSessionToJson(_VideoSession instance) =>
    <String, dynamic>{
      'updated_at': instance.updatedAt.toIso8601String(),
      'video_record': instance.videoRecord.toJson(),
      'progress': instance.progress.toJson(),
      'subtitle_uri': instance.subtitleUri,
    };

_History _$HistoryFromJson(Map<String, dynamic> json) => _History(
      value: (json['value'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, VideoSession.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$HistoryToJson(_History instance) => <String, dynamic>{
      'value': instance.value.map((k, e) => MapEntry(k, e.toJson())),
    };
