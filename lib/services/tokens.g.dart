// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BungaToken _$BungaTokenFromJson(Map<String, dynamic> json) => BungaToken(
      clientID: json['clientID'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$BungaTokenToJson(BungaToken instance) =>
    <String, dynamic>{
      'clientID': instance.clientID,
      'token': instance.token,
    };

StreamIOToken _$StreamIOTokenFromJson(Map<String, dynamic> json) =>
    StreamIOToken(
      appKey: json['key'] as String,
      userToken: json['user_token'] as String,
    );

Map<String, dynamic> _$StreamIOTokenToJson(StreamIOToken instance) =>
    <String, dynamic>{
      'key': instance.appKey,
      'user_token': instance.userToken,
    };

AgoraToken _$AgoraTokenFromJson(Map<String, dynamic> json) => AgoraToken(
      appKey: json['key'] as String,
    );

Map<String, dynamic> _$AgoraTokenToJson(AgoraToken instance) =>
    <String, dynamic>{
      'key': instance.appKey,
    };
