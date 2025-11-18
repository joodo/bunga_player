// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientAccount _$ClientAccountFromJson(Map<String, dynamic> json) =>
    _ClientAccount(
      id: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$ClientAccountToJson(_ClientAccount instance) =>
    <String, dynamic>{'username': instance.id, 'password': instance.password};
