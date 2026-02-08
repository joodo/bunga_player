// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallMessageData _$CallMessageDataFromJson(Map<String, dynamic> json) =>
    CallMessageData(action: $enumDecode(_$CallActionEnumMap, json['action']));

Map<String, dynamic> _$CallMessageDataToJson(CallMessageData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'action': _$CallActionEnumMap[instance.action]!,
    };

const _$CallActionEnumMap = {
  CallAction.call: 'call',
  CallAction.accept: 'accept',
  CallAction.reject: 'reject',
  CallAction.cancel: 'cancel',
};

TalkStatusMessageData _$TalkStatusMessageDataFromJson(
  Map<String, dynamic> json,
) => TalkStatusMessageData(
  status: $enumDecode(_$TalkStatusEnumMap, json['status']),
);

Map<String, dynamic> _$TalkStatusMessageDataToJson(
  TalkStatusMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'status': _$TalkStatusEnumMap[instance.status]!,
};

const _$TalkStatusEnumMap = {TalkStatus.start: 'start', TalkStatus.end: 'end'};
