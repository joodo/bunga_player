import 'package:json_annotation/json_annotation.dart';

part 'file_info.g.dart';

enum AListFileType {
  @JsonValue(1)
  folder,
  @JsonValue(2)
  video,
  @JsonValue(3)
  audio,
  @JsonValue(4)
  text,
  @JsonValue(5)
  image,
  @JsonValue(0)
  unknown,
}

@JsonSerializable()
class AListFileInfo {
  final String name;
  final int size;
  final AListFileType type;
  final DateTime created;
  final DateTime modified;
  final String thumb;
  final String sign;

  AListFileInfo({
    required this.name,
    required this.size,
    required this.type,
    required this.created,
    required this.modified,
    required this.thumb,
    required this.sign,
  });

  factory AListFileInfo.fromJson(Map<String, dynamic> json) =>
      _$AListFileInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AListFileInfoToJson(this);

  @override
  String toString() => toJson().toString();
}
