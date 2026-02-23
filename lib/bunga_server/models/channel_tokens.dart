import 'dart:convert';

import 'package:bunga_player/services/logger.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'channel_tokens.g.dart';

@JsonSerializable()
class Token {
  final String access;
  final String refresh;

  Token({required this.access, required this.refresh});

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class VoiceCallInfo {
  final String key;
  final String channelToken;

  VoiceCallInfo({required this.key, required this.channelToken});

  factory VoiceCallInfo.fromJson(Map<String, dynamic> json) =>
      _$VoiceCallInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceCallInfoToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class BilibiliInfo {
  final String sess;
  final String mixinKey;

  BilibiliInfo({required this.sess, required this.mixinKey});

  factory BilibiliInfo.fromJson(Map<String, dynamic> json) =>
      _$BilibiliInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BilibiliInfoToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class AListInfo {
  final String host;
  final String token;

  AListInfo({required this.host, required this.token});

  factory AListInfo.fromJson(Map<String, dynamic> json) =>
      _$AListInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AListInfoToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class ChannelInfo {
  @JsonKey(name: 'channel_id')
  final String id;
  final String name;

  ChannelInfo({required this.id, required this.name});

  factory ChannelInfo.fromJson(Map<String, dynamic> json) =>
      _$ChannelInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelInfoToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}

@JsonSerializable()
class ChannelTokens {
  @JsonKey(name: 'token')
  Token _token;
  final Uri origin;
  final ChannelInfo channel;
  final VoiceCallInfo? voiceCall;
  final BilibiliInfo? bilibili;
  final AListInfo? alist;

  ChannelTokens({
    required Token token,
    required this.channel,
    required this.origin,
    this.voiceCall,
    this.bilibili,
    this.alist,
  }) : _token = token;

  Token get token => _token;

  Future<Token> refreshToken() async {
    final response = await http.post(
      origin.replace(path: '/api/token/refresh/'),
      body: _token.toJson(),
    );
    final responseData = jsonDecode(response.body);
    responseData['refresh'] = _token.refresh;
    _token = Token.fromJson(responseData);
    logger.i('Refreshed new access token: ${_token.access}');
    return _token;
  }

  factory ChannelTokens.fromJson(Map<String, dynamic> json) =>
      _$ChannelTokensFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelTokensToJson(this);

  @override
  String toString() => jsonEncode(toJson());
}
