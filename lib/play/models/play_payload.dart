import 'dart:convert';

import 'video_record.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_payload.freezed.dart';
part 'play_payload.g.dart';

@freezed
abstract class Source with _$Source {
  const Source._();

  const factory Source({String? name, required String url}) = _Source;

  factory Source.fromJson(Map<String, dynamic> json) => _$SourceFromJson(json);
}

@freezed
abstract class VideoSources with _$VideoSources {
  const VideoSources._();

  const factory VideoSources({
    required List<Source> videos,
    List<Source>? audios,
    Map<String, String>? requestHeaders,
  }) = _VideoSources;

  factory VideoSources.single(
    String url, {
    Map<String, String>? requestHeaders,
  }) => VideoSources(
    videos: [Source(url: url)],
    requestHeaders: requestHeaders,
  );

  factory VideoSources.fromJson(Map<String, dynamic> json) =>
      _$VideoSourcesFromJson(json);
}

@freezed
abstract class PlayPayload with _$PlayPayload {
  const PlayPayload._();

  const factory PlayPayload({
    required VideoRecord record,
    required VideoSources sources,
    @Default(0) int videoSourceIndex,
  }) = _PlayPayload;

  factory PlayPayload.fromJson(Map<String, dynamic> json) =>
      _$PlayPayloadFromJson(json);

  @override
  String toString() => jsonEncode(toJson());
}
