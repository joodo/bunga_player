// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientAccount _$ClientAccountFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ClientAccount', json, ($checkedConvert) {
      final val = _ClientAccount(
        id: $checkedConvert('username', (v) => v as String),
        password: $checkedConvert('password', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'id': 'username'});

Map<String, dynamic> _$ClientAccountToJson(_ClientAccount instance) =>
    <String, dynamic>{'username': instance.id, 'password': instance.password};
