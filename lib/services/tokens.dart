import 'dart:convert';

import 'package:bunga_player/constants/global_keys.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/utils/http_response.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:window_manager/window_manager.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tokens.g.dart';

class Tokens {
  // Singleton
  static final _instance = Tokens._internal();
  factory Tokens() => _instance;
  Tokens._internal();

  late final BungaToken bunga;
  late final StreamIOToken streamIO;
  late final AgoraToken agora;

  Future<void> init() async {
    String? clientID = Preferences().get<String>('client_id');
    if (clientID == null) {
      clientID = const Uuid().v4();
      Preferences().set('client_id', clientID);
    }

    http.Response? response;
    String? errMessage;
    while (true) {
      errMessage = null;
      try {
        response = await http.post(
          Uri.parse('https://www.joodo.club/api/auth/login'),
          body: {'user_id': clientID},
        );
        if (!response.isSuccess) errMessage = response.body;
      } catch (e) {
        errMessage = e.toString();
      }
      if (errMessage == null) break;

      await showDialog(
        context: rootNavigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.error),
          title: const Text('魔法失灵'),
          content: Text('也许再试试会好，也许不会。\n$errMessage'),
          actions: <Widget>[
            TextButton(
              onPressed: () => windowManager.close(),
              child: const Text('退出'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final data = jsonDecode(response!.body);
    bunga = BungaToken(clientID: clientID, token: data['api_token']);
    streamIO = StreamIOToken.fromJson(data['stream_io']);
    agora = AgoraToken.fromJson(data['agora_key']);
  }
}

@JsonSerializable()
class BungaToken {
  BungaToken({required this.clientID, required this.token});

  String clientID;
  String token;

  factory BungaToken.fromJson(Map<String, dynamic> json) =>
      _$BungaTokenFromJson(json);
  Map<String, dynamic> toJson() => _$BungaTokenToJson(this);
}

@JsonSerializable()
class StreamIOToken {
  StreamIOToken({required this.appKey, required this.userToken});

  @JsonKey(name: 'key')
  String appKey;
  @JsonKey(name: 'user_token')
  String userToken;

  factory StreamIOToken.fromJson(Map<String, dynamic> json) =>
      _$StreamIOTokenFromJson(json);
  Map<String, dynamic> toJson() => _$StreamIOTokenToJson(this);
}

@JsonSerializable()
class AgoraToken {
  AgoraToken({required this.appKey});

  @JsonKey(name: 'key')
  String appKey;

  factory AgoraToken.fromJson(Map<String, dynamic> json) =>
      _$AgoraTokenFromJson(json);
  Map<String, dynamic> toJson() => _$AgoraTokenToJson(this);
}
