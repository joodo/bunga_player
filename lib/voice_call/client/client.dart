import 'dart:async';

import 'package:bunga_player/utils/models/volume.dart';
import 'package:flutter/cupertino.dart';

abstract class VoiceCallClient {
  ValueNotifier<Volume> get volumeNotifier;

  void setMuteMic(bool mute);

  Future<void> joinChannel({required String userId});
  Future<void> leaveChannel();
}
