// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchProgress _$WatchProgressFromJson(Map<String, dynamic> json) =>
    WatchProgress(
      position: (json['position'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$WatchProgressToJson(WatchProgress instance) =>
    <String, dynamic>{
      'position': instance.position,
      'duration': instance.duration,
    };

VideoSession _$VideoSessionFromJson(Map<String, dynamic> json) => VideoSession(
      json['hash'] as String,
      progress: json['progress'] == null
          ? null
          : WatchProgress.fromJson(json['progress'] as Map<String, dynamic>),
      subtitleUri: json['subtitleUri'] as String?,
    );

Map<String, dynamic> _$VideoSessionToJson(VideoSession instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'progress': instance.progress,
      'subtitleUri': instance.subtitleUri,
    };
