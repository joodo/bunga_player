import 'package:json_annotation/json_annotation.dart';

part 'watch_progress.g.dart';

@JsonSerializable()
class WatchProgress {
  final int progress;
  final int duration;

  WatchProgress({required this.progress, required this.duration});

  double get percent => progress / duration;

  factory WatchProgress.fromJson(Map<String, dynamic> json) =>
      _$WatchProgressFromJson(json);
  Map<String, dynamic> toJson() => _$WatchProgressToJson(this);

  @override
  String toString() => toJson().toString();
}
