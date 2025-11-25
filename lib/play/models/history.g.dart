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
      videoRecord: VideoRecord.fromJson(
        json['video_record'] as Map<String, dynamic>,
      ),
      progress: json['progress'] == null
          ? null
          : WatchProgress.fromJson(json['progress'] as Map<String, dynamic>),
      subtitlePath: json['subtitle_path'] as String?,
    );

Map<String, dynamic> _$VideoSessionToJson(_VideoSession instance) =>
    <String, dynamic>{
      'updated_at': instance.updatedAt.toIso8601String(),
      'video_record': instance.videoRecord.toJson(),
      'progress': instance.progress?.toJson(),
      'subtitle_path': instance.subtitlePath,
    };
