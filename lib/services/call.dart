import 'dart:async';

abstract class CallService {
  Future<void> setVolume(double percent);
  Future<void> setMuteMic(bool mute);

  Future<Stream<int>> joinChannel();
  Future<void> leaveChannel();
}
