// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Linker _$LinkerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Linker', json, ($checkedConvert) {
      final val = Linker(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LinkerToJson(Linker instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
};

MediaSummary _$MediaSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MediaSummary', json, ($checkedConvert) {
      final val = MediaSummary(
        key: $checkedConvert('key', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        thumbUrl: $checkedConvert('thumb_url', (v) => v as String?),
        year: $checkedConvert('year', (v) => (v as num?)?.toInt()),
        country: $checkedConvert('country', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'thumbUrl': 'thumb_url'});

Map<String, dynamic> _$MediaSummaryToJson(MediaSummary instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'thumb_url': instance.thumbUrl,
      'year': instance.year,
      'country': instance.country,
    };

Episode _$EpisodeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Episode', json, ($checkedConvert) {
      final val = Episode(
        id: $checkedConvert('id', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        thumbUrl: $checkedConvert('thumb_url', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'thumbUrl': 'thumb_url'});

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'thumb_url': instance.thumbUrl,
};

Media _$MediaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Media', json, ($checkedConvert) {
      final val = Media(
        origin: $checkedConvert('origin', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        thumbUrl: $checkedConvert('thumb_url', (v) => v as String?),
        year: $checkedConvert('year', (v) => (v as num?)?.toInt()),
        country: $checkedConvert('country', (v) => v as String?),
        aka: $checkedConvert('aka', (v) => v as String?),
        director: $checkedConvert(
          'director',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        cast: $checkedConvert(
          'cast',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        genres: $checkedConvert(
          'genres',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        summary: $checkedConvert('summary', (v) => v as String?),
        episodes: $checkedConvert(
          'episodes',
          (v) => (v as List<dynamic>)
              .map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'thumbUrl': 'thumb_url'});

Map<String, dynamic> _$MediaToJson(Media instance) => <String, dynamic>{
  'origin': instance.origin,
  'title': instance.title,
  'thumb_url': instance.thumbUrl,
  'year': instance.year,
  'country': instance.country,
  'aka': instance.aka,
  'director': instance.director,
  'cast': instance.cast,
  'genres': instance.genres,
  'summary': instance.summary,
  'episodes': instance.episodes.map((e) => e.toJson()).toList(),
};

Source _$SourceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Source', json, ($checkedConvert) {
      final val = Source(
        title: $checkedConvert('title', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SourceToJson(Source instance) => <String, dynamic>{
  'title': instance.title,
  'url': instance.url,
};
