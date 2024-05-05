import 'package:bunga_player/chat/models/user.dart';

typedef MessageData = Map<String, dynamic>;

class Message {
  final String id;
  final MessageData data;
  final User sender;

  Message({
    required this.id,
    required this.data,
    required this.sender,
  });
}
