// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoSources _$VideoSourcesFromJson(
  Map<String, dynamic> json,
) => _VideoSources(
  videos: (json['videos'] as List<dynamic>).map((e) => e as String).toList(),
  audios: (json['audios'] as List<dynamic>?)?.map((e) => e as String).toList(),
  requestHeaders: (json['request_headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$VideoSourcesToJson(_VideoSources instance) =>
    <String, dynamic>{
      'videos': instance.videos,
      'audios': instance.audios,
      'request_headers': instance.requestHeaders,
    };

_PlayPayload _$PlayPayloadFromJson(Map<String, dynamic> json) => _PlayPayload(
  record: VideoRecord.fromJson(json['record'] as Map<String, dynamic>),
  sources: VideoSources.fromJson(json['sources'] as Map<String, dynamic>),
  videoSourceIndex: (json['video_source_index'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayPayloadToJson(_PlayPayload instance) =>
    <String, dynamic>{
      'record': instance.record.toJson(),
      'sources': instance.sources.toJson(),
      'video_source_index': instance.videoSourceIndex,
    };
