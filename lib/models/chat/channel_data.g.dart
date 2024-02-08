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
    );

Map<String, dynamic> _$ChannelDataToJson(ChannelData instance) =>
    <String, dynamic>{
      'video_type': _$VideoTypeEnumMap[instance.videoType]!,
      'name': instance.name,
      'hash': instance.videoHash,
      'image': instance.image,
      'sharer': instance.sharer,
    };

const _$VideoTypeEnumMap = {
  VideoType.local: 'local',
  VideoType.online: 'online',
};
