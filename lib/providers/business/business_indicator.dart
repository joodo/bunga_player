import 'package:flutter/material.dart';

class Mission {
  final String name;
  final List<Future Function()> tasks;

  Mission({required this.name, required this.tasks});
}

class BusinessIndicator extends ChangeNotifier {
  String? currentMissionName;
  int? currentProgress, totalProgress;

  bool _isRunning = false;
  Future<void> run({
    required List<Mission> missions,
    bool showProgress = true,
    bool determinate = false,
  }) async {
    assert(!_isRunning);
    _isRunning = true;

    if (determinate) {
      totalProgress = missions.fold<int>(
        0,
        (previousValue, element) => previousValue += element.tasks.length,
      );
    }

    if (showProgress) currentProgress = 0;

    try {
      for (final mission in missions) {
        currentMissionName = mission.name;
        for (final task in mission.tasks) {
          notifyListeners();
          await task();
          if (currentProgress != null) currentProgress = currentProgress! + 1;
        }
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
}
