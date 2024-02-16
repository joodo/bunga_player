import 'dart:async';

abstract class CallService {
  String get appId;

  Future<void> setVolume(double percent);
  Future<void> setMuteMic(bool mute);

  Future<Stream<int>> joinChannel();
  Future<void> leaveChannel();
}
