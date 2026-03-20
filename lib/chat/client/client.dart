import 'package:flutter/foundation.dart';

import '../models/json_message.dart';

abstract class ChatClient {
  Future<JsonMessage?> sendMessage(Map<String, dynamic> data);
  Stream<JsonMessage> get messageStream;
  ValueListenable<bool> get isConnectedNotifier;

  void dispose() {}
}
