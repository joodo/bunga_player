// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallMessageData _$CallMessageDataFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CallMessageData', json, ($checkedConvert) {
      final val = CallMessageData(
        action: $checkedConvert(
          'action',
          (v) => $enumDecode(_$CallActionEnumMap, v),
        ),
      );
      return val;
    });

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
) => $checkedCreate('TalkStatusMessageData', json, ($checkedConvert) {
  final val = TalkStatusMessageData(
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$TalkStatusEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$TalkStatusMessageDataToJson(
  TalkStatusMessageData instance,
) => <String, dynamic>{
  'code': instance.code,
  'status': _$TalkStatusEnumMap[instance.status]!,
};

const _$TalkStatusEnumMap = {TalkStatus.start: 'start', TalkStatus.end: 'end'};
