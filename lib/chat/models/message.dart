import 'package:bunga_player/chat/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String text;
  final User sender;
  final String? quoteId;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    this.quoteId,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
  @override
  String toString() => toJson().toString();
}
