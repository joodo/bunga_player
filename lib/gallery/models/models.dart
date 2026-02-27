import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class Linker {
  final String id;
  final String name;
  final String url;

  Linker({required this.id, required this.name, required this.url});

  factory Linker.fromJson(Map<String, dynamic> json) => _$LinkerFromJson(json);

  Map<String, dynamic> toJson() => _$LinkerToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class MediaSummary {
  final String key;
  final String title;

  final String? thumbUrl;
  final int? year;
  final String? country;

  MediaSummary({
    required this.key,
    required this.title,
    this.thumbUrl,
    this.year,
    this.country,
  });

  factory MediaSummary.fromJson(Map<String, dynamic> json) =>
      _$MediaSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MediaSummaryToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class Episode {
  final String id;
  final String title;
  final String? thumbUrl;

  Episode({required this.id, required this.title, this.thumbUrl});

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class Media {
  final String origin;
  final String title;

  final String? thumbUrl;
  final int? year;
  final String? country;
  final String? aka;
  final List<String>? director;
  final List<String>? cast;
  final List<String>? genres;
  final String? summary;

  final List<Episode> episodes;

  Media({
    required this.origin,
    required this.title,
    this.thumbUrl,
    this.year,
    this.country,
    this.aka,
    this.director,
    this.cast,
    this.genres,
    this.summary,
    required this.episodes,
  });

  factory Media.fromJson(Map<String, dynamic> json) => _$MediaFromJson(json);

  Map<String, dynamic> toJson() => _$MediaToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class Source {
  final String title;
  final String url;

  Source({required this.title, required this.url});

  factory Source.fromJson(Map<String, dynamic> json) => _$SourceFromJson(json);

  Map<String, dynamic> toJson() => _$SourceToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
