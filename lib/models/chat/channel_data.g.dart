// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelData _$ChannelDataFromJson(Map<String, dynamic> json) => ChannelData(
      videoType: $enumDecode(_$VideoTypeEnumMap, json['video_type']),
      name: json['name'] as String,
      videoHash: json['hash'] as String,
      pic: json['pic'] as String?,
    );

Map<String, dynamic> _$ChannelDataToJson(ChannelData instance) =>
    <String, dynamic>{
      'video_type': _$VideoTypeEnumMap[instance.videoType]!,
      'name': instance.name,
      'hash': instance.videoHash,
      'pic': instance.pic,
    };

const _$VideoTypeEnumMap = {
  VideoType.local: 'local',
  VideoType.bilibili: 'bilibili',
};
