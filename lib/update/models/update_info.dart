import 'package:json_annotation/json_annotation.dart';

part 'update_info.g.dart';

@JsonSerializable()
class UpdateInfo {
  final DateTime checkedAt;
  final String version;
  final String name;
  final String body;
  final String downloadUrl;

  UpdateInfo({
    required this.checkedAt,
    required this.version,
    required this.name,
    required this.body,
    required this.downloadUrl,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) =>
      _$UpdateInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateInfoToJson(this);
}
