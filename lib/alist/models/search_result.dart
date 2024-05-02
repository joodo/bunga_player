import 'package:bunga_player/alist/models/file_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_result.g.dart';

@JsonSerializable()
class AListSearchResult {
  final String name;
  final int size;
  final AListFileType type;
  final String parent;

  AListSearchResult({
    required this.name,
    required this.size,
    required this.type,
    required this.parent,
  });

  factory AListSearchResult.fromJson(Map<String, dynamic> json) =>
      _$AListSearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$AListSearchResultToJson(this);

  @override
  String toString() => toJson().toString();
}
