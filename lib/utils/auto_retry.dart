import 'dart:async';

import 'package:bunga_player/services/logger.dart';

class JobCanceledException implements Exception {}

class AutoRetryJob<T> {
  final Future<T> Function() _job;
  final String? jobName;
  final Duration coolDown;

  AutoRetryJob(
    this._job, {
    this.jobName,
    this.coolDown = const Duration(seconds: 2),
  });

  int _times = 0;
  int get times => _times;

  final _completer = Completer<Null>();

  Future<T?> run() async {
    if (_times > 0) throw Exception('Job already running');

    final result = await Future.any<T?>([
      _completer.future,
      () async {
        while (true) {
          try {
            _times++;
            return await _job();
          } catch (e) {
            final calculatedCoolDown = coolDown * _times;
            logger.w(
                'Failed job $jobName: $e.\nWait ${calculatedCoolDown.inSeconds} seconds then try ${_times + 1}st time.');
            await Future.delayed(calculatedCoolDown);
          }
        }
      }(),
    ]);

    if (!_completer.isCompleted) _completer.complete();
    return result;
  }

  void cancelIfNotFinished() {
    if (!_completer.isCompleted) _completer.complete();
  }
}
