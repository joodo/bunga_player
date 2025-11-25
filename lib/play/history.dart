import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/typedef.dart';

import 'models/history.dart';
import 'models/video_record.dart';

class History extends DelegatingMap<String, VideoSession> {
  static int maxCount = 50;

  History() : super({});

  // Load and save
  static Future<File> _getHistoryFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/play_history.json');
    return file;
  }

  File? _file;
  Future<void> load() async {
    _file ??= await _getHistoryFile();
    if (!await _file!.exists()) return;

    final content = await _file!.readAsString();

    late final List<JsonMap> list;
    try {
      list = jsonDecode(content);
    } catch (e) {
      logger.w('History: failed to load json file ${_file!.path}: $e');
      return;
    }
    for (final json in list) {
      try {
        final session = VideoSession.fromJson(json);
        this[session.videoRecord.id] = session;
      } catch (e) {
        logger.w('History: failed to load session ${jsonEncode(json)}');
      }
    }
  }

  Future<void> save() async {
    _file ??= await _getHistoryFile();

    if (length > maxCount) {
      final list = values
          .sortedBy((element) => element.updatedAt)
          .reversed
          .toList()
          .sublist(0, min(length, maxCount))
          .map((e) => e.toJson());

      try {
        await _file!.writeAsString(jsonEncode(list));
      } catch (e) {
        logger.w('History: failed to save json file ${_file!.path}: $e');
      }
    }
  }

  // Update
  void updateProgress(VideoRecord record, WatchProgress? progress) {
    final session =
        this[record.id] ??
        VideoSession(updatedAt: DateTime(0), videoRecord: record);
    this[record.id] = session.copyWith(
      updatedAt: DateTime.now(),
      videoRecord: record,
      progress: progress,
    );
  }

  void updateSubtitle(VideoRecord record, String? path) {
    final session =
        this[record.id] ??
        VideoSession(updatedAt: DateTime(0), videoRecord: record);
    this[record.id] = session.copyWith(
      updatedAt: DateTime.now(),
      videoRecord: record,
      subtitlePath: path,
    );
  }
}
