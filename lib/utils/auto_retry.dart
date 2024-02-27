import 'package:bunga_player/services/logger.dart';

// TODO: use RetryClient
// see https://pub.dev/documentation/http/latest/retry/RetryClient-class.html
Future<T> autoRetry<T>(
  Future<T> Function() job, {
  String jobName = '',
  Duration coolDown = const Duration(seconds: 1),
}) async {
  int times = 0;
  while (true) {
    try {
      return await job();
    } catch (e) {
      times++;
      logger.w(
          'Failed job $jobName: $e.\nWait ${coolDown.inSeconds} seconds then try ${times}st time.');
      await Future.delayed(coolDown);
    }
  }
}
