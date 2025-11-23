// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoRecord _$VideoRecordFromJson(Map<String, dynamic> json) => _VideoRecord(
  id: json['record_id'] as String,
  title: json['title'] as String,
  thumbUrl: json['thumb_url'] as String?,
  source: json['source'] as String,
  path: json['path'] as String,
);

Map<String, dynamic> _$VideoRecordToJson(_VideoRecord instance) =>
    <String, dynamic>{
      'record_id': instance.id,
      'title': instance.title,
      'thumb_url': instance.thumbUrl,
      'source': instance.source,
      'path': instance.path,
    };
