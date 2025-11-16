// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateInfo _$UpdateInfoFromJson(Map<String, dynamic> json) => UpdateInfo(
      checkedAt: DateTime.parse(json['checked_at'] as String),
      version: json['version'] as String,
      name: json['name'] as String,
      body: json['body'] as String,
      downloadUrl: json['download_url'] as String,
    );

Map<String, dynamic> _$UpdateInfoToJson(UpdateInfo instance) =>
    <String, dynamic>{
      'checked_at': instance.checkedAt.toIso8601String(),
      'version': instance.version,
      'name': instance.name,
      'body': instance.body,
      'download_url': instance.downloadUrl,
    };
