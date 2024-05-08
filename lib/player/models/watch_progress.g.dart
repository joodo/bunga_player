// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchProgress _$WatchProgressFromJson(Map<String, dynamic> json) =>
    WatchProgress(
      progress: (json['progress'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$WatchProgressToJson(WatchProgress instance) =>
    <String, dynamic>{
      'progress': instance.progress,
      'duration': instance.duration,
    };
