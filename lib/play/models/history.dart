import 'package:freezed_annotation/freezed_annotation.dart';

import 'video_record.dart';

part 'history.freezed.dart';
part 'history.g.dart';

@freezed
abstract class WatchProgress with _$WatchProgress {
  const WatchProgress._();

  const factory WatchProgress({
    required Duration position,
    required Duration duration,
  }) = _WatchProgress;

  factory WatchProgress.fromJson(Map<String, dynamic> json) =>
      _$WatchProgressFromJson(json);

  double get ratio => duration.inMilliseconds == 0
      ? 0
      : position.inMilliseconds / duration.inMilliseconds;
}

@freezed
abstract class VideoSession with _$VideoSession {
  const factory VideoSession({
    required DateTime updatedAt,
    required VideoRecord videoRecord,
    WatchProgress? progress,
    String? subtitlePath,
  }) = _VideoSession;

  factory VideoSession.fromJson(Map<String, dynamic> json) =>
      _$VideoSessionFromJson(json);
}
