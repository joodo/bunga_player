// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AListFileInfo _$AListFileInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AListFileInfo', json, ($checkedConvert) {
      final val = AListFileInfo(
        name: $checkedConvert('name', (v) => v as String),
        size: $checkedConvert('size', (v) => (v as num).toInt()),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$AListFileTypeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AListFileInfoToJson(AListFileInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'size': instance.size,
      'type': _$AListFileTypeEnumMap[instance.type]!,
    };

const _$AListFileTypeEnumMap = {
  AListFileType.folder: 1,
  AListFileType.video: 2,
  AListFileType.audio: 3,
  AListFileType.text: 4,
  AListFileType.image: 5,
  AListFileType.unknown: 0,
};

AListFileDetail _$AListFileDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AListFileDetail', json, ($checkedConvert) {
      final val = AListFileDetail(
        name: $checkedConvert('name', (v) => v as String),
        size: $checkedConvert('size', (v) => (v as num).toInt()),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$AListFileTypeEnumMap, v),
        ),
        created: $checkedConvert('created', (v) => DateTime.parse(v as String)),
        modified: $checkedConvert(
          'modified',
          (v) => DateTime.parse(v as String),
        ),
        thumb: $checkedConvert('thumb', (v) => v as String),
        sign: $checkedConvert('sign', (v) => v as String),
        rawUrl: $checkedConvert('raw_url', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'rawUrl': 'raw_url'});

Map<String, dynamic> _$AListFileDetailToJson(AListFileDetail instance) =>
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

AListSearchResult _$AListSearchResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AListSearchResult', json, ($checkedConvert) {
      final val = AListSearchResult(
        name: $checkedConvert('name', (v) => v as String),
        size: $checkedConvert('size', (v) => (v as num).toInt()),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$AListFileTypeEnumMap, v),
        ),
        parent: $checkedConvert('parent', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AListSearchResultToJson(AListSearchResult instance) =>
    <String, dynamic>{
      'name': instance.name,
      'size': instance.size,
      'type': _$AListFileTypeEnumMap[instance.type]!,
      'parent': instance.parent,
    };
