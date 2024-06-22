import 'package:json_annotation/json_annotation.dart';

part 'video_session.g.dart';

@JsonSerializable()
class WatchProgress {
  // TODO: change to Duration
  final int position;
  final int duration;

  const WatchProgress({required this.position, required this.duration});

  double get percent => position / duration;

  factory WatchProgress.fromJson(Map<String, dynamic> json) =>
      _$WatchProgressFromJson(json);
  Map<String, dynamic> toJson() => _$WatchProgressToJson(this);

  @override
  String toString() => toJson().toString();
}

@JsonSerializable()
class VideoSession {
  final String hash;
  final DateTime createdAt;

  DateTime _updatedAt;
  DateTime get updatedAt => _updatedAt;

  WatchProgress? _progress;
  WatchProgress? get progress => _progress;
  set progress(WatchProgress? value) {
    _progress = value;
    _updatedAt = DateTime.now();
  }

  String? _subtitleUri;
  String? get subtitleUri => _subtitleUri;
  set subtitleUri(String? value) {
    _subtitleUri = value;
    _updatedAt = DateTime.now();
  }

  factory VideoSession.fromJson(Map<String, dynamic> json) =>
      _$VideoSessionFromJson(json);
  Map<String, dynamic> toJson() => _$VideoSessionToJson(this);

  VideoSession(
    this.hash, {
    WatchProgress? progress,
    String? subtitleUri,
  })  : createdAt = DateTime.now(),
        _updatedAt = DateTime.now(),
        _progress = progress,
        _subtitleUri = subtitleUri;
}
