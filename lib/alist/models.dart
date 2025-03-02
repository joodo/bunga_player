import 'package:bunga_player/utils/business/comparators.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

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
class AListFileInfo implements Comparable {
  final String name;
  final int size;
  final AListFileType type;

  AListFileInfo({
    required this.name,
    required this.size,
    required this.type,
  });

  factory AListFileInfo.fromJson(Map<String, dynamic> json) =>
      _$AListFileInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AListFileInfoToJson(this);

  @override
  String toString() => toJson().toString();

  @override
  int compareTo(other) {
    final sortFunc = compareBy((AListFileInfo e) => e.type.index).then(
      compareBy((AListFileInfo e) => e.name, compareNatural),
    );
    return sortFunc(this, other);
  }
}

@JsonSerializable()
class AListFileDetail extends AListFileInfo {
  final DateTime created;
  final DateTime modified;
  final String thumb;
  final String sign;
  final String? rawUrl;

  AListFileDetail({
    required super.name,
    required super.size,
    required super.type,
    required this.created,
    required this.modified,
    required this.thumb,
    required this.sign,
    this.rawUrl,
  });

  factory AListFileDetail.fromJson(Map<String, dynamic> json) =>
      _$AListFileDetailFromJson(json);
  Map<String, dynamic> toJson() => _$AListFileDetailToJson(this);

  @override
  String toString() => toJson().toString();
}

@JsonSerializable()
class AListSearchResult extends AListFileInfo {
  final String parent;

  AListSearchResult({
    required super.name,
    required super.size,
    required super.type,
    required this.parent,
  });

  factory AListSearchResult.fromJson(Map<String, dynamic> json) =>
      _$AListSearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$AListSearchResultToJson(this);

  @override
  String toString() => toJson().toString();
}
