import 'user.dart';
import 'json_message.dart';
import 'message_data.dart';

class Message {
  final MessageData data;
  final User sender;

  Message({required this.data, required this.sender});

  Message.fromJson(JsonMessage message)
    : sender = message.sender,
      data = MessageData.fromJson(message.data);
}
