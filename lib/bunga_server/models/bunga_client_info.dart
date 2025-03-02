import 'package:freezed_annotation/freezed_annotation.dart';

part 'bunga_client_info.freezed.dart';
part 'bunga_client_info.g.dart';

@freezed
abstract class IMInfo with _$IMInfo {
  const factory IMInfo({
    required String appId,
    required String userSig,
  }) = _IMInfo;

  factory IMInfo.fromJson(Map<String, dynamic> json) => _$IMInfoFromJson(json);
}

@freezed
abstract class VoiceCallInfo with _$VoiceCallInfo {
  const factory VoiceCallInfo({required String key}) = _VoiceCallInfo;

  factory VoiceCallInfo.fromJson(Map<String, dynamic> json) =>
      _$VoiceCallInfoFromJson(json);
}

@freezed
abstract class BilibiliInfo with _$BilibiliInfo {
  const factory BilibiliInfo({
    required String sess,
    required String mixinKey,
  }) = _BilibiliInfo;

  factory BilibiliInfo.fromJson(Map<String, dynamic> json) =>
      _$BilibiliInfoFromJson(json);
}

@freezed
abstract class AListInfo with _$AListInfo {
  const factory AListInfo({
    required String host,
    required String token,
  }) = _AListInfo;

  factory AListInfo.fromJson(Map<String, dynamic> json) =>
      _$AListInfoFromJson(json);
}

@freezed
abstract class ChannelInfo with _$ChannelInfo {
  const factory ChannelInfo({
    required String id,
    required String name,
  }) = _ChannelInfo;

  factory ChannelInfo.fromJson(Map<String, dynamic> json) =>
      _$ChannelInfoFromJson(json);
}

@freezed
abstract class BungaClientInfo with _$BungaClientInfo {
  const factory BungaClientInfo({
    required String token,
    required ChannelInfo channel,
    required IMInfo im,
    VoiceCallInfo? voiceCall,
    BilibiliInfo? bilibili,
    AListInfo? alist,
  }) = _BungaClientInfo;

  factory BungaClientInfo.fromJson(Map<String, dynamic> json) =>
      _$BungaClientInfoFromJson(json);
}
