import 'dart:async';

abstract class CallClient {
  Future<void> setVolume(double percent);
  Future<void> setMuteMic(bool mute);

  Future<Stream<int>> joinChannel(dynamic channelData);
  Future<void> leaveChannel();
}
