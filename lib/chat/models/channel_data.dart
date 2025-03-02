import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/video_entries/video_entry.dart';
import 'package:json_annotation/json_annotation.dart';

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
    this.path,
  });

  factory ChannelData.fromShare(User sharer, VideoEntry videoEntry) =>
      ChannelData(
        videoType:
            videoEntry is LocalVideoEntry ? VideoType.local : VideoType.online,
        name: videoEntry.title,
        videoHash: videoEntry.hash,
        sharer: sharer,
        path: videoEntry.path,
        image: videoEntry.image,
      );

  @JsonKey(name: videoTypeJsonKey)
  final VideoType videoType;
  final String name;
  @JsonKey(name: 'hash')
  final String videoHash;
  final User sharer;
  final String? image;
  final String? path;

  @override
  bool operator ==(Object other) =>
      other is ChannelData &&
      videoType == other.videoType &&
      name == other.name &&
      videoHash == other.videoHash &&
      image == other.image &&
      sharer.id == other.sharer.id &&
      path == other.path;

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
        path,
      );
}
