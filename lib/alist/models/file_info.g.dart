// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AListFileInfo _$AListFileInfoFromJson(Map<String, dynamic> json) =>
    AListFileInfo(
      name: json['name'] as String,
      size: json['size'] as int,
      type: $enumDecode(_$AListFileTypeEnumMap, json['type']),
      created: DateTime.parse(json['created'] as String),
      modified: DateTime.parse(json['modified'] as String),
      thumb: json['thumb'] as String,
      sign: json['sign'] as String,
      rawUrl: json['raw_url'] as String?,
    );

Map<String, dynamic> _$AListFileInfoToJson(AListFileInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'size': instance.size,
      'type': _$AListFileTypeEnumMap[instance.type]!,
      'created': instance.created.toIso8601String(),
      'modified': instance.modified.toIso8601String(),
      'thumb': instance.thumb,
      'sign': instance.sign,
      'raw_url': instance.rawUrl,
    };

const _$AListFileTypeEnumMap = {
  AListFileType.folder: 1,
  AListFileType.video: 2,
  AListFileType.audio: 3,
  AListFileType.text: 4,
  AListFileType.image: 5,
  AListFileType.unknown: 0,
};
