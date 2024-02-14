import 'dart:async';

abstract class CallService {
  String get appId;

  Future<void> setVolume(double percent);

  Future<Stream<int>> joinChannel();
  Future<void> leaveChannel();
}
