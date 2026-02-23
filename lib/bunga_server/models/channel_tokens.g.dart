// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Token', json, ($checkedConvert) {
      final val = Token(
        access: $checkedConvert('access', (v) => v as String),
        refresh: $checkedConvert('refresh', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'access': instance.access,
  'refresh': instance.refresh,
};

VoiceCallInfo _$VoiceCallInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VoiceCallInfo', json, ($checkedConvert) {
      final val = VoiceCallInfo(
        key: $checkedConvert('key', (v) => v as String),
        channelToken: $checkedConvert('channel_token', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'channelToken': 'channel_token'});

Map<String, dynamic> _$VoiceCallInfoToJson(VoiceCallInfo instance) =>
    <String, dynamic>{
      'key': instance.key,
      'channel_token': instance.channelToken,
    };

BilibiliInfo _$BilibiliInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BilibiliInfo', json, ($checkedConvert) {
      final val = BilibiliInfo(
        sess: $checkedConvert('sess', (v) => v as String),
        mixinKey: $checkedConvert('mixin_key', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'mixinKey': 'mixin_key'});

Map<String, dynamic> _$BilibiliInfoToJson(BilibiliInfo instance) =>
    <String, dynamic>{'sess': instance.sess, 'mixin_key': instance.mixinKey};

AListInfo _$AListInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AListInfo', json, ($checkedConvert) {
      final val = AListInfo(
        host: $checkedConvert('host', (v) => v as String),
        token: $checkedConvert('token', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AListInfoToJson(AListInfo instance) => <String, dynamic>{
  'host': instance.host,
  'token': instance.token,
};

ChannelInfo _$ChannelInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChannelInfo', json, ($checkedConvert) {
      final val = ChannelInfo(
        id: $checkedConvert('channel_id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'id': 'channel_id'});

Map<String, dynamic> _$ChannelInfoToJson(ChannelInfo instance) =>
    <String, dynamic>{'channel_id': instance.id, 'name': instance.name};

ChannelTokens _$ChannelTokensFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ChannelTokens', json, ($checkedConvert) {
  final val = ChannelTokens(
    token: $checkedConvert(
      'token',
      (v) => Token.fromJson(v as Map<String, dynamic>),
    ),
    channel: $checkedConvert(
      'channel',
      (v) => ChannelInfo.fromJson(v as Map<String, dynamic>),
    ),
    origin: $checkedConvert('origin', (v) => Uri.parse(v as String)),
    voiceCall: $checkedConvert(
      'voice_call',
      (v) =>
          v == null ? null : VoiceCallInfo.fromJson(v as Map<String, dynamic>),
    ),
    bilibili: $checkedConvert(
      'bilibili',
      (v) =>
          v == null ? null : BilibiliInfo.fromJson(v as Map<String, dynamic>),
    ),
    alist: $checkedConvert(
      'alist',
      (v) => v == null ? null : AListInfo.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'voiceCall': 'voice_call'});

Map<String, dynamic> _$ChannelTokensToJson(ChannelTokens instance) =>
    <String, dynamic>{
      'origin': instance.origin.toString(),
      'channel': instance.channel.toJson(),
      'voice_call': instance.voiceCall?.toJson(),
      'bilibili': instance.bilibili?.toJson(),
      'alist': instance.alist?.toJson(),
      'token': instance.token.toJson(),
    };
