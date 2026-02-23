// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BufferStateChangedMessageData _$BufferStateChangedMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'BufferStateChangedMessageData',
  json,
  ($checkedConvert) {
    final val = BufferStateChangedMessageData(
      $checkedConvert('is_buffering', (v) => v as bool),
    );
    return val;
  },
  fieldKeyMap: const {'isBuffering': 'is_buffering'},
);

Map<String, dynamic> _$BufferStateChangedMessageDataToJson(
  BufferStateChangedMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'is_buffering': instance.isBuffering,
};

PlayMessageData _$PlayMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlayMessageData', json, ($checkedConvert) {
      final val = PlayMessageData();
      return val;
    });

Map<String, dynamic> _$PlayMessageDataToJson(PlayMessageData instance) =>
    <String, dynamic>{'code': instance.code};

PauseMessageData _$PauseMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PauseMessageData', json, ($checkedConvert) {
      final val = PauseMessageData(
        position: $checkedConvert(
          'position',
          (v) => Duration(microseconds: (v as num).toInt()),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PauseMessageDataToJson(PauseMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'position': instance.position.inMicroseconds,
    };

SeekMessageData _$SeekMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SeekMessageData', json, ($checkedConvert) {
      final val = SeekMessageData(
        position: $checkedConvert(
          'position',
          (v) => Duration(microseconds: (v as num).toInt()),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SeekMessageDataToJson(SeekMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'position': instance.position.inMicroseconds,
    };

PlayFinishedMessageData _$PlayFinishedMessageDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PlayFinishedMessageData', json, ($checkedConvert) {
  final val = PlayFinishedMessageData();
  return val;
});

Map<String, dynamic> _$PlayFinishedMessageDataToJson(
  PlayFinishedMessageData instance,
) => <String, dynamic>{'code': instance.code};

PlayAtMessageData _$PlayAtMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlayAtMessageData', json, ($checkedConvert) {
      final val = PlayAtMessageData(
        position: $checkedConvert(
          'position',
          (v) => Duration(microseconds: (v as num).toInt()),
        ),
        isPlay: $checkedConvert('is_play', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'isPlay': 'is_play'});

Map<String, dynamic> _$PlayAtMessageDataToJson(PlayAtMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'position': instance.position.inMicroseconds,
      'is_play': instance.isPlay,
    };

ShareSubMessageData _$ShareSubMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ShareSubMessageData', json, ($checkedConvert) {
      final val = ShareSubMessageData(
        url: $checkedConvert('url', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ShareSubMessageDataToJson(
  ShareSubMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'url': instance.url,
  'title': instance.title,
};
