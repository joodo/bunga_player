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

extension FilterDataTypeExtension on Stream<Message> {
  Stream<({User sender, T data})> whereDataType<T>() => where(
    (message) => message.data is T,
  ).map((message) => (sender: message.sender, data: message.data as T));
}
