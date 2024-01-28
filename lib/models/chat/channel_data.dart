import 'package:json_annotation/json_annotation.dart';

part 'channel_data.g.dart';

enum VideoType {
  local,
  bilibili,
}

@JsonSerializable()
class ChannelData {
  static const videoTypeJsonKey = 'video_type';

  ChannelData({
    required this.videoType,
    required this.name,
    required this.videoHash,
    this.pic,
  });

  @JsonKey(name: videoTypeJsonKey)
  final VideoType videoType;
  @JsonKey()
  final String name;
  @JsonKey(name: 'hash')
  final String videoHash;
  @JsonKey()
  final String? pic;

  factory ChannelData.fromJson(Map<String, dynamic> json) =>
      _$ChannelDataFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelDataToJson(this);
}
