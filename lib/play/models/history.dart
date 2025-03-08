import 'dart:convert';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/string.dart';
import 'package:collection/collection.dart';
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

  double get ratio => position.inMilliseconds / duration.inMilliseconds;
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

@Freezed(makeCollectionsUnmodifiable: false)
abstract class History with _$History {
  static const preferencesKey = 'history';
  static int maxCount = 50;

  const History._();

  const factory History({
    required Map<String, VideoSession> value,
  }) = _History;

  factory History.load() {
    try {
      final historyStr = getIt<Preferences>().get<String>(preferencesKey);
      final decompressed = historyStr!.decompress();
      final json = jsonDecode(decompressed);
      return History.fromJson(json);
    } catch (e) {
      logger.w('Failed to load history: $e');
      // ignore: prefer_const_constructors
      return History(value: {});
    }
  }

  factory History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);

  static const _notPassedProgress = WatchProgress(
    position: Duration(milliseconds: -1),
    duration: Duration(milliseconds: -1),
  );
  static const _notPassedSubPath = 'NOTPASSED';
  void update({
    required VideoRecord videoRecord,
    WatchProgress? progress = _notPassedProgress,
    String? subtitlePath = _notPassedSubPath,
  }) {
    final current = value[videoRecord.id];
    if (current != null) {
      value[videoRecord.id] = current.copyWith(
        updatedAt: DateTime.now(),
        progress: identical(progress, _notPassedProgress)
            ? current.progress
            : progress,
        subtitlePath: identical(subtitlePath, _notPassedSubPath)
            ? current.subtitlePath
            : subtitlePath,
      );
    } else {
      value[videoRecord.id] = VideoSession(
        videoRecord: videoRecord,
        updatedAt: DateTime.now(),
        progress: identical(progress, _notPassedProgress) ? null : progress,
        subtitlePath:
            identical(subtitlePath, _notPassedSubPath) ? null : subtitlePath,
      );
    }
  }

  Future<void> save() {
    if (value.length > maxCount) {
      value.values
          .sortedBy((element) => element.updatedAt)
          .reversed
          .toList()
          .sublist(50)
          .map((e) {
        value.remove(e.videoRecord.id);
      });
    }

    final compressed = jsonEncode(toJson()).compress();
    return getIt<Preferences>().set(preferencesKey, compressed);
  }
}
