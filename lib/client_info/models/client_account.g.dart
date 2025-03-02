// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClientAccountImpl _$$ClientAccountImplFromJson(Map<String, dynamic> json) =>
    _$ClientAccountImpl(
      id: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$ClientAccountImplToJson(_$ClientAccountImpl instance) =>
    <String, dynamic>{
      'username': instance.id,
      'password': instance.password,
    };
