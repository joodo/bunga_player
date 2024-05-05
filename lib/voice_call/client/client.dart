import 'dart:async';

abstract class VoiceCallClient {
  Future<void> setVolume(double percent);
  Future<void> setMuteMic(bool mute);

  Future<void> joinChannel({required String userId, required String channelId});
  Future<void> leaveChannel();
}
