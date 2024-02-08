import 'package:json_annotation/json_annotation.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

part 'channel_data.g.dart';

enum VideoType {
  local,
  online,
}

@JsonSerializable()
class ChannelData {
  static const videoTypeJsonKey = 'video_type';

  ChannelData({
    required this.videoType,
    required this.name,
    required this.videoHash,
    required this.sharer,
    this.image,
  });

  @JsonKey(name: videoTypeJsonKey)
  final VideoType videoType;
  final String name;
  @JsonKey(name: 'hash')
  final String videoHash;
  final String? image;
  final User sharer;

  @override
  bool operator ==(Object other) =>
      other is ChannelData &&
      videoType == other.videoType &&
      name == other.name &&
      videoHash == other.videoHash &&
      image == other.image &&
      sharer.id == other.sharer.id;

  factory ChannelData.fromJson(Map<String, dynamic> json) =>
      _$ChannelDataFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelDataToJson(this);

  @override
  String toString() => toJson().toString();

  @override
  int get hashCode => Object.hash(
        videoType,
        name,
        videoHash,
        image,
        sharer.id,
      );
}
