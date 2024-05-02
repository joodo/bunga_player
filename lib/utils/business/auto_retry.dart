import 'dart:async';

import 'package:bunga_player/services/logger.dart';

class JobCanceledException implements Exception {}

class JobAlreadyRunning implements Exception {}

class JobExpired<T> implements Exception {
  final T? result;

  JobExpired({this.result});
}

class JobTryOut implements Exception {}

class AutoRetryJob<T> {
  final Future<T> Function() _job;
  final String? jobName;
  final Duration coolDown;
  final bool Function()? alive;
  final int? maxTries;

  AutoRetryJob(
    this._job, {
    this.jobName,
    this.coolDown = const Duration(seconds: 3),
    this.alive,
    this.maxTries,
  });

  int _times = 0;
  int get times => _times;

  final _completer = Completer<Null>();

  void _checkAlive([T? result]) {
    if (alive?.call() == false) throw JobExpired(result: result);
  }

  Future<T> run() async {
    if (_times > 0) throw JobAlreadyRunning();

    final result = await Future.any<T>([
      () async {
        await _completer.future;
        throw JobCanceledException();
      }(),
      () async {
        late final T result;

        while (true) {
          _checkAlive();

          _times++;
          try {
            result = await _job();
            break;
          } catch (e) {
            if (_times == maxTries) throw JobTryOut();

            final calculatedCoolDown = coolDown * _times;
            logger.w(
                'Failed job $jobName: $e.\nWait ${calculatedCoolDown.inSeconds} seconds then try ${_times + 1}st time.');
            await Future.delayed(calculatedCoolDown);
          }
        }

        _checkAlive(result);
        return result;
      }(),
    ]);

    if (!_completer.isCompleted) _completer.complete();
    return result;
  }

  void cancelIfNotFinished() {
    if (!_completer.isCompleted) _completer.complete();
  }
}
