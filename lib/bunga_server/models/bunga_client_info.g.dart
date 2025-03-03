// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bunga_client_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IMInfoImpl _$$IMInfoImplFromJson(Map<String, dynamic> json) => _$IMInfoImpl(
      appId: json['app_id'] as String,
      userId: json['user_id'] as String,
      userSig: json['user_sig'] as String,
    );

Map<String, dynamic> _$$IMInfoImplToJson(_$IMInfoImpl instance) =>
    <String, dynamic>{
      'app_id': instance.appId,
      'user_id': instance.userId,
      'user_sig': instance.userSig,
    };

_$VoiceCallInfoImpl _$$VoiceCallInfoImplFromJson(Map<String, dynamic> json) =>
    _$VoiceCallInfoImpl(
      key: json['key'] as String,
    );

Map<String, dynamic> _$$VoiceCallInfoImplToJson(_$VoiceCallInfoImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
    };

_$BilibiliInfoImpl _$$BilibiliInfoImplFromJson(Map<String, dynamic> json) =>
    _$BilibiliInfoImpl(
      sess: json['sess'] as String,
      mixinKey: json['mixin_key'] as String,
    );

Map<String, dynamic> _$$BilibiliInfoImplToJson(_$BilibiliInfoImpl instance) =>
    <String, dynamic>{
      'sess': instance.sess,
      'mixin_key': instance.mixinKey,
    };

_$AListInfoImpl _$$AListInfoImplFromJson(Map<String, dynamic> json) =>
    _$AListInfoImpl(
      host: json['host'] as String,
      token: json['token'] as String,
    );

Map<String, dynamic> _$$AListInfoImplToJson(_$AListInfoImpl instance) =>
    <String, dynamic>{
      'host': instance.host,
      'token': instance.token,
    };

_$ChannelInfoImpl _$$ChannelInfoImplFromJson(Map<String, dynamic> json) =>
    _$ChannelInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$ChannelInfoImplToJson(_$ChannelInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$BungaClientInfoImpl _$$BungaClientInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$BungaClientInfoImpl(
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

Map<String, dynamic> _$$BungaClientInfoImplToJson(
        _$BungaClientInfoImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'channel': instance.channel,
      'im': instance.im,
      'voice_call': instance.voiceCall,
      'bilibili': instance.bilibili,
      'alist': instance.alist,
    };
