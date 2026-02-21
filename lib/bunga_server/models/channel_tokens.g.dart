// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) =>
    Token(access: json['access'] as String, refresh: json['refresh'] as String);

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'access': instance.access,
  'refresh': instance.refresh,
};

IMInfo _$IMInfoFromJson(Map<String, dynamic> json) => IMInfo(
  appId: json['app_id'] as String,
  userId: json['user_id'] as String,
  userSig: json['user_sig'] as String,
);

Map<String, dynamic> _$IMInfoToJson(IMInfo instance) => <String, dynamic>{
  'app_id': instance.appId,
  'user_id': instance.userId,
  'user_sig': instance.userSig,
};

VoiceCallInfo _$VoiceCallInfoFromJson(Map<String, dynamic> json) =>
    VoiceCallInfo(
      key: json['key'] as String,
      channelToken: json['channel_token'] as String,
    );

Map<String, dynamic> _$VoiceCallInfoToJson(VoiceCallInfo instance) =>
    <String, dynamic>{
      'key': instance.key,
      'channel_token': instance.channelToken,
    };

BilibiliInfo _$BilibiliInfoFromJson(Map<String, dynamic> json) => BilibiliInfo(
  sess: json['sess'] as String,
  mixinKey: json['mixin_key'] as String,
);

Map<String, dynamic> _$BilibiliInfoToJson(BilibiliInfo instance) =>
    <String, dynamic>{'sess': instance.sess, 'mixin_key': instance.mixinKey};

AListInfo _$AListInfoFromJson(Map<String, dynamic> json) =>
    AListInfo(host: json['host'] as String, token: json['token'] as String);

Map<String, dynamic> _$AListInfoToJson(AListInfo instance) => <String, dynamic>{
  'host': instance.host,
  'token': instance.token,
};

ChannelInfo _$ChannelInfoFromJson(Map<String, dynamic> json) =>
    ChannelInfo(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$ChannelInfoToJson(ChannelInfo instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

ChannelTokens _$ChannelTokensFromJson(Map<String, dynamic> json) =>
    ChannelTokens(
      token: Token.fromJson(json['token'] as Map<String, dynamic>),
      channel: ChannelInfo.fromJson(json['channel'] as Map<String, dynamic>),
      im: IMInfo.fromJson(json['im'] as Map<String, dynamic>),
      origin: Uri.parse(json['origin'] as String),
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

Map<String, dynamic> _$ChannelTokensToJson(ChannelTokens instance) =>
    <String, dynamic>{
      'origin': instance.origin.toString(),
      'channel': instance.channel.toJson(),
      'im': instance.im.toJson(),
      'voice_call': instance.voiceCall?.toJson(),
      'bilibili': instance.bilibili?.toJson(),
      'alist': instance.alist?.toJson(),
      'token': instance.token.toJson(),
    };
