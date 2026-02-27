// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Source _$SourceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Source', json, ($checkedConvert) {
      final val = _Source(
        name: $checkedConvert('name', (v) => v as String?),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SourceToJson(_Source instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
};

_VideoSources _$VideoSourcesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_VideoSources', json, ($checkedConvert) {
      final val = _VideoSources(
        videos: $checkedConvert(
          'videos',
          (v) => (v as List<dynamic>)
              .map((e) => Source.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        audios: $checkedConvert(
          'audios',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Source.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        requestHeaders: $checkedConvert(
          'request_headers',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ),
        ),
      );
      return val;
    }, fieldKeyMap: const {'requestHeaders': 'request_headers'});

Map<String, dynamic> _$VideoSourcesToJson(_VideoSources instance) =>
    <String, dynamic>{
      'videos': instance.videos.map((e) => e.toJson()).toList(),
      'audios': instance.audios?.map((e) => e.toJson()).toList(),
      'request_headers': instance.requestHeaders,
    };

_PlayPayload _$PlayPayloadFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PlayPayload', json, ($checkedConvert) {
      final val = _PlayPayload(
        record: $checkedConvert(
          'record',
          (v) => VideoRecord.fromJson(v as Map<String, dynamic>),
        ),
        sources: $checkedConvert(
          'sources',
          (v) => VideoSources.fromJson(v as Map<String, dynamic>),
        ),
        videoSourceIndex: $checkedConvert(
          'video_source_index',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
      );
      return val;
    }, fieldKeyMap: const {'videoSourceIndex': 'video_source_index'});

Map<String, dynamic> _$PlayPayloadToJson(_PlayPayload instance) =>
    <String, dynamic>{
      'record': instance.record.toJson(),
      'sources': instance.sources.toJson(),
      'video_source_index': instance.videoSourceIndex,
    };
