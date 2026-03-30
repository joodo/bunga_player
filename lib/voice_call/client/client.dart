import 'dart:async';

import 'package:flutter/foundation.dart';

import '/utils/utils.dart';

abstract class VoiceCallClient {
  ValueNotifier<Volume> get volumeNotifier;

  ValueNotifier<bool> get micMuteNotifier;

  Future<void> joinChannel({required String userId});
  Future<void> leaveChannel();

  void dispose() {}
}
