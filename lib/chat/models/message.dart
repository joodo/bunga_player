import 'package:bunga_player/chat/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
class Message {
  final Map<String, dynamic> data;
  final User sender;

  Message({required this.data, required this.sender});

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
