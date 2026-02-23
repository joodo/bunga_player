// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoRecord _$VideoRecordFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_VideoRecord', json, ($checkedConvert) {
      final val = _VideoRecord(
        id: $checkedConvert('record_id', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        thumbUrl: $checkedConvert('thumb_url', (v) => v as String?),
        source: $checkedConvert('source', (v) => v as String),
        path: $checkedConvert('path', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'id': 'record_id', 'thumbUrl': 'thumb_url'});

Map<String, dynamic> _$VideoRecordToJson(_VideoRecord instance) =>
    <String, dynamic>{
      'record_id': instance.id,
      'title': instance.title,
      'thumb_url': instance.thumbUrl,
      'source': instance.source,
      'path': instance.path,
    };
