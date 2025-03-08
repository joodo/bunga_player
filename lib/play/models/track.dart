import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';

@freezed
abstract class AudioTrack with _$AudioTrack {
  factory AudioTrack(
    String id, [
    String? title,
    String? language,
  ]) = _AudioTrack;
}

@freezed
abstract class SubtitleTrack with _$SubtitleTrack {
  factory SubtitleTrack({
    required String id,
    String? title,
    String? language,
    String? path,
  }) = _SubtitleTrack;
}
