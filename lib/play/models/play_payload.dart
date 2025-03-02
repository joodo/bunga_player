import 'video_record.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_payload.freezed.dart';

class VideoSources {
  final List<String> videos;
  final List<String>? audios;

  VideoSources({required this.videos, this.audios});
  VideoSources.single(String url)
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
