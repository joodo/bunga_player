// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateInfo _$UpdateInfoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'UpdateInfo',
  json,
  ($checkedConvert) {
    final val = UpdateInfo(
      checkedAt: $checkedConvert(
        'checked_at',
        (v) => DateTime.parse(v as String),
      ),
      version: $checkedConvert('version', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      body: $checkedConvert('body', (v) => v as String),
      downloadUrl: $checkedConvert('download_url', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'checkedAt': 'checked_at', 'downloadUrl': 'download_url'},
);

Map<String, dynamic> _$UpdateInfoToJson(UpdateInfo instance) =>
    <String, dynamic>{
      'checked_at': instance.checkedAt.toIso8601String(),
      'version': instance.version,
      'name': instance.name,
      'body': instance.body,
      'download_url': instance.downloadUrl,
    };
