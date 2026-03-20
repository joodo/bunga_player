// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonMessage _$JsonMessageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('JsonMessage', json, ($checkedConvert) {
      final val = JsonMessage(
        data: $checkedConvert('data', (v) => v as Map<String, dynamic>),
        sender: $checkedConvert(
          'sender',
          (v) => User.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$JsonMessageToJson(JsonMessage instance) =>
    <String, dynamic>{
      'data': instance.data,
      'sender': instance.sender.toJson(),
    };
