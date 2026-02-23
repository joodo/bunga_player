// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Message', json, ($checkedConvert) {
      final val = Message(
        data: $checkedConvert('data', (v) => v as Map<String, dynamic>),
        sender: $checkedConvert(
          'sender',
          (v) => User.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'data': instance.data,
  'sender': instance.sender.toJson(),
};
