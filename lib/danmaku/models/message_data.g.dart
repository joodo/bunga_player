// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PopmojiMessageData _$PopmojiMessageDataFromJson(Map<String, dynamic> json) =>
    PopmojiMessageData(popmojiCode: json['popmoji_code'] as String);

Map<String, dynamic> _$PopmojiMessageDataToJson(PopmojiMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'popmoji_code': instance.popmojiCode,
    };

DanmakuMessageData _$DanmakuMessageDataFromJson(Map<String, dynamic> json) =>
    DanmakuMessageData(message: json['message'] as String);

Map<String, dynamic> _$DanmakuMessageDataToJson(DanmakuMessageData instance) =>
    <String, dynamic>{'code': instance.code, 'message': instance.message};

SparkMessageData _$SparkMessageDataFromJson(Map<String, dynamic> json) =>
    SparkMessageData(
      emoji: json['emoji'] as String,
      fraction: SparkMessageData._fractionalOffsetFromJson(
        json['fraction'] as List,
      ),
    );

Map<String, dynamic> _$SparkMessageDataToJson(SparkMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'emoji': instance.emoji,
      'fraction': SparkMessageData._fractionalOffsetToJson(instance.fraction),
    };
