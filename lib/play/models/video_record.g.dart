// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoRecordImpl _$$VideoRecordImplFromJson(Map<String, dynamic> json) =>
    _$VideoRecordImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbUrl: json['thumb_url'] as String?,
      source: json['source'] as String,
      path: json['path'] as String,
    );

Map<String, dynamic> _$$VideoRecordImplToJson(_$VideoRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'thumb_url': instance.thumbUrl,
      'source': instance.source,
      'path': instance.path,
    };
