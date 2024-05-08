// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AListSearchResult _$AListSearchResultFromJson(Map<String, dynamic> json) =>
    AListSearchResult(
      name: json['name'] as String,
      size: (json['size'] as num).toInt(),
      type: $enumDecode(_$AListFileTypeEnumMap, json['type']),
      parent: json['parent'] as String,
    );

Map<String, dynamic> _$AListSearchResultToJson(AListSearchResult instance) =>
    <String, dynamic>{
      'name': instance.name,
      'size': instance.size,
      'type': _$AListFileTypeEnumMap[instance.type]!,
      'parent': instance.parent,
    };

const _$AListFileTypeEnumMap = {
  AListFileType.folder: 1,
  AListFileType.video: 2,
  AListFileType.audio: 3,
  AListFileType.text: 4,
  AListFileType.image: 5,
  AListFileType.unknown: 0,
};
