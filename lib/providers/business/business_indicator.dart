import 'package:flutter/material.dart';

typedef Task = Future Function(dynamic data);

class BusinessIndicator extends ChangeNotifier {
  String? currentMissionName;
  int? currentProgress, totalProgress;

  bool _isRunning = false;
  Future<void> run({
    required List<Task> tasks,
    bool showProgress = true,
    bool determinate = false,
  }) async {
    assert(!_isRunning);
    _isRunning = true;

    if (determinate) {
      totalProgress = tasks.length;
    }

    if (showProgress) currentProgress = 0;

    dynamic result;
    try {
      for (final task in tasks) {
        result = await task(result);
        if (currentProgress != null) currentProgress = currentProgress! + 1;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    } finally {
      totalProgress = null;
      currentProgress = null;
      currentMissionName = null;
      notifyListeners();

      _isRunning = false;
    }
  }

  Task setTitle(String? title) => (dynamic data) async {
        currentMissionName = title;
        return data;
      };

  Task setTitleFromLastTask(String? Function(dynamic lastResult) getTitle) =>
      (dynamic data) async {
        currentMissionName = getTitle(data);
        return data;
      };
}
