// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelData _$ChannelDataFromJson(Map<String, dynamic> json) => ChannelData(
      videoType: $enumDecode(_$VideoTypeEnumMap, json['video_type']),
      name: json['name'] as String,
      videoHash: json['hash'] as String,
      sharer: User.fromJson(json['sharer'] as Map<String, dynamic>),
      image: json['image'] as String?,
      path: json['path'] as String?,
    );

Map<String, dynamic> _$ChannelDataToJson(ChannelData instance) =>
    <String, dynamic>{
      'video_type': _$VideoTypeEnumMap[instance.videoType]!,
      'name': instance.name,
      'hash': instance.videoHash,
      'sharer': instance.sharer.toJson(),
      'image': instance.image,
      'path': instance.path,
    };

const _$VideoTypeEnumMap = {
  VideoType.local: 'local',
  VideoType.online: 'online',
};
