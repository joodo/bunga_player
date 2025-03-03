import 'video_record.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_payload.freezed.dart';

@immutable
class VideoSources {
  final List<String> videos;
  final List<String>? audios;
  final Map<String, String>? requestHeaders;

  const VideoSources({
    required this.videos,
    this.audios,
    this.requestHeaders,
  });
  VideoSources.single(String url, {this.requestHeaders})
      : videos = [url],
        audios = null;

  @override
  String toString() {
    return {
      'videos': videos.toString(),
      'audios': audios.toString(),
    }.toString();
  }
}

@freezed
abstract class PlayPayload with _$PlayPayload {
  factory PlayPayload({
    required VideoRecord record,
    required VideoSources sources,
    @Default(0) int videoSourceIndex,
  }) = _PlayPayload;
}
