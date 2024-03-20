import 'dart:convert';

import 'package:bunga_player/providers/clients/online_video.dart';
import 'package:bunga_player/utils/http_response.dart';
import 'package:http/http.dart' as http;

class NeedEpisodeIndexException implements Exception {
  final Iterable<String> episodeNames;
  NeedEpisodeIndexException(this.episodeNames);
}

class StreamIOClientInfo {
  final String appKey;
  final String userToken;

  StreamIOClientInfo({required this.appKey, required this.userToken});
}

class AListClientInfo {
  final String host;
  final String token;

  AListClientInfo({required this.host, required this.token});
}

class BungaClient {
  BungaClient(String host) : _host = Uri.parse(host);

  final Uri _host;
  String get host => _host.toString();

  Future<void> register(String clientId) async {
    final response = await http.post(
      _host.resolve('auth/register'),
      body: {'user_id': clientId},
    );
    if (!response.isSuccess) {
      throw Exception('Login failed: ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    _streamIOClientInfo = StreamIOClientInfo(
      appKey: responseData['stream_io']['app_key'],
      userToken: responseData['stream_io']['user_token'],
    );
    _userToken = _streamIOClientInfo.userToken;
    _agoraClientAppKey = responseData['agora'];
    _biliSess = responseData['bilibili_sess'];
    final alistData = responseData['alist'];
    _aListClientInfo = alistData == null
        ? null
        : AListClientInfo(
            host: alistData['host'],
            token: alistData['token'],
          );
  }

  late final StreamIOClientInfo _streamIOClientInfo;
  StreamIOClientInfo get streamIOClientInfo => _streamIOClientInfo;

  late final String _agoraClientAppKey;
  String get agoraClientAppKey => _agoraClientAppKey;

  late final String? _biliSess;
  String? get biliSess => _biliSess;

  late final AListClientInfo? _aListClientInfo;
  AListClientInfo? get aListClientInfo => _aListClientInfo;

  late final String _userToken;

  Future<Map> parseVideoUrl(String url) async {
    final response = await http.post(
      _host.resolve('video-parse'),
      headers: {'Authorization': _userToken},
      body: {'url': url},
    );
    if (!response.isSuccess) {
      if (response.statusCode == 418) {
        final list = jsonDecode(response.body)['episodes'] as List;
        throw NeedEpisodeIndexException(list.map((e) => e as String));
      } else {
        throw Exception('Parse video failed: ${response.body}');
      }
    }
    return jsonDecode(response.body);
  }

  Future<Iterable<SupportSite>> getSupportSites() async {
    final request = http.Request(
      'OPTIONS',
      _host.resolve('video-parse'),
    );
    final streamedResponse = await http.Client().send(request);
    final response = await http.Response.fromStream(streamedResponse);
    if (!response.isSuccess) {
      throw Exception('Parse support sites failed: ${response.body}');
    }

    final list = jsonDecode(response.body)['supports'] as List;
    return list.map(
      (result) => SupportSite(
        name: result['name'],
        url: result['url'],
      ),
    );
  }
}
