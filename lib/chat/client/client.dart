import '../models/message.dart';

abstract class ChatClient {
  Future<Message> sendMessage(Map<String, dynamic> data);
}
