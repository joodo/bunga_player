import 'package:json_annotation/json_annotation.dart';

part 'app_key.g.dart';

@JsonSerializable()
class AppKey {
  AppKey({required this.streamIO, required this.agora});

  @JsonKey(name: 'stream_io')
  final String streamIO;
  @JsonKey(name: 'agora')
  final String agora;

  factory AppKey.fromJson(Map<String, dynamic> json) => _$AppKeyFromJson(json);
  Map<String, dynamic> toJson() => _$AppKeyToJson(this);

  @override
  String toString() => toJson().toString();
}
