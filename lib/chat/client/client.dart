import 'package:flutter/foundation.dart';

import '../models/message.dart';

abstract class ChatClient {
  Future<Message?> sendMessage(Map<String, dynamic> data);
  Stream<Message> get messageStream;
  ValueListenable<bool> get isConnectedNotifier;

  void dispose() {}
}
