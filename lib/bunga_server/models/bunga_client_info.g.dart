// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bunga_client_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IMInfo _$IMInfoFromJson(Map<String, dynamic> json) => _IMInfo(
      appId: json['app_id'] as String,
      userId: json['user_id'] as String,
      userSig: json['user_sig'] as String,
    );

Map<String, dynamic> _$IMInfoToJson(_IMInfo instance) => <String, dynamic>{
      'app_id': instance.appId,
      'user_id': instance.userId,
      'user_sig': instance.userSig,
    };

_VoiceCallInfo _$VoiceCallInfoFromJson(Map<String, dynamic> json) =>
    _VoiceCallInfo(
      key: json['key'] as String,
      channelToken: json['channel_token'] as String,
    );

Map<String, dynamic> _$VoiceCallInfoToJson(_VoiceCallInfo instance) =>
    <String, dynamic>{
      'key': instance.key,
      'channel_token': instance.channelToken,
    };

_BilibiliInfo _$BilibiliInfoFromJson(Map<String, dynamic> json) =>
    _BilibiliInfo(
      sess: json['sess'] as String,
      mixinKey: json['mixin_key'] as String,
    );

Map<String, dynamic> _$BilibiliInfoToJson(_BilibiliInfo instance) =>
    <String, dynamic>{
      'sess': instance.sess,
      'mixin_key': instance.mixinKey,
    };

_AListInfo _$AListInfoFromJson(Map<String, dynamic> json) => _AListInfo(
      host: json['host'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$AListInfoToJson(_AListInfo instance) =>
    <String, dynamic>{
      'host': instance.host,
      'token': instance.token,
    };

_ChannelInfo _$ChannelInfoFromJson(Map<String, dynamic> json) => _ChannelInfo(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ChannelInfoToJson(_ChannelInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_BungaClientInfo _$BungaClientInfoFromJson(Map<String, dynamic> json) =>
    _BungaClientInfo(
      token: json['token'] as String,
      channel: ChannelInfo.fromJson(json['channel'] as Map<String, dynamic>),
      im: IMInfo.fromJson(json['im'] as Map<String, dynamic>),
      voiceCall: json['voice_call'] == null
          ? null
          : VoiceCallInfo.fromJson(json['voice_call'] as Map<String, dynamic>),
      bilibili: json['bilibili'] == null
          ? null
          : BilibiliInfo.fromJson(json['bilibili'] as Map<String, dynamic>),
      alist: json['alist'] == null
          ? null
          : AListInfo.fromJson(json['alist'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BungaClientInfoToJson(_BungaClientInfo instance) =>
    <String, dynamic>{
      'token': instance.token,
      'channel': instance.channel.toJson(),
      'im': instance.im.toJson(),
      'voice_call': instance.voiceCall?.toJson(),
      'bilibili': instance.bilibili?.toJson(),
      'alist': instance.alist?.toJson(),
    };
