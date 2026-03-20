import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/utils/typedef.dart';

part 'json_message.g.dart';

@JsonSerializable(explicitToJson: true)
class JsonMessage {
  final JsonMap data;
  final User sender;

  JsonMessage({required this.data, required this.sender});

  factory JsonMessage.fromJson(JsonMap json) => _$JsonMessageFromJson(json);

  Map<String, dynamic> toJson() => _$JsonMessageToJson(this);
}
