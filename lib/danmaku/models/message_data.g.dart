// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PopmojiMessageData _$PopmojiMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PopmojiMessageData', json, ($checkedConvert) {
      final val = PopmojiMessageData(
        popmojiCode: $checkedConvert('popmoji_code', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'popmojiCode': 'popmoji_code'});

Map<String, dynamic> _$PopmojiMessageDataToJson(PopmojiMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'popmoji_code': instance.popmojiCode,
    };

DanmakuMessageData _$DanmakuMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DanmakuMessageData', json, ($checkedConvert) {
      final val = DanmakuMessageData(
        message: $checkedConvert('message', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$DanmakuMessageDataToJson(DanmakuMessageData instance) =>
    <String, dynamic>{'code': instance.code, 'message': instance.message};

SparkMessageData _$SparkMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SparkMessageData', json, ($checkedConvert) {
      final val = SparkMessageData(
        emoji: $checkedConvert('emoji', (v) => v as String),
        fraction: $checkedConvert(
          'fraction',
          (v) => SparkMessageData._fractionalOffsetFromJson(v as List),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SparkMessageDataToJson(SparkMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'emoji': instance.emoji,
      'fraction': SparkMessageData._fractionalOffsetToJson(instance.fraction),
    };
