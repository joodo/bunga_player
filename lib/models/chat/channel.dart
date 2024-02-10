import 'package:json_annotation/json_annotation.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import 'channel_data.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User creator;
  final ChannelData data;

  Channel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.creator,
    required this.data,
  });

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelToJson(this);

  @override
  String toString() => toJson().toString();
}
