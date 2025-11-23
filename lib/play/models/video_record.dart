import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_record.freezed.dart';
part 'video_record.g.dart';

@freezed
abstract class VideoRecord with _$VideoRecord {
  const factory VideoRecord({
    @JsonKey(name: 'record_id') required String id,
    required String title,
    String? thumbUrl,
    required String source,
    required String path,
  }) = _VideoRecord;

  factory VideoRecord.fromJson(Map<String, dynamic> json) =>
      _$VideoRecordFromJson(json);
}
