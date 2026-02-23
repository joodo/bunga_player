// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WatchProgress _$WatchProgressFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_WatchProgress', json, ($checkedConvert) {
      final val = _WatchProgress(
        position: $checkedConvert(
          'position',
          (v) => Duration(microseconds: (v as num).toInt()),
        ),
        duration: $checkedConvert(
          'duration',
          (v) => Duration(microseconds: (v as num).toInt()),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WatchProgressToJson(_WatchProgress instance) =>
    <String, dynamic>{
      'position': instance.position.inMicroseconds,
      'duration': instance.duration.inMicroseconds,
    };

_VideoSession _$VideoSessionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_VideoSession',
      json,
      ($checkedConvert) {
        final val = _VideoSession(
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => DateTime.parse(v as String),
          ),
          videoRecord: $checkedConvert(
            'video_record',
            (v) => VideoRecord.fromJson(v as Map<String, dynamic>),
          ),
          progress: $checkedConvert(
            'progress',
            (v) => v == null
                ? null
                : WatchProgress.fromJson(v as Map<String, dynamic>),
          ),
          subtitlePath: $checkedConvert('subtitle_path', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'updatedAt': 'updated_at',
        'videoRecord': 'video_record',
        'subtitlePath': 'subtitle_path',
      },
    );

Map<String, dynamic> _$VideoSessionToJson(_VideoSession instance) =>
    <String, dynamic>{
      'updated_at': instance.updatedAt.toIso8601String(),
      'video_record': instance.videoRecord.toJson(),
      'progress': instance.progress?.toJson(),
      'subtitle_path': instance.subtitlePath,
    };
