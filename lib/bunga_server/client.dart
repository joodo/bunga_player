import 'dart:convert';
import 'dart:typed_data';

import 'package:bunga_player/bunga_server/models.dart';
import 'package:bunga_player/online_video/client.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';
import 'package:http/http.dart' as http;

class NeedEpisodeIndexException implements Exception {
  final Iterable<String> episodeNames;
  NeedEpisodeIndexException(this.episodeNames);
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

    final chatInfo = responseData['chat'];
    switch (chatInfo['service']) {
      case 'stream_io':
        _chatClientInfo = StreamIOClientInfo.fromJson(chatInfo);
      case 'tencent':
        _chatClientInfo = TencentClientInfo.fromJson(chatInfo);
    }
    _userToken = _chatClientInfo.userToken;

    final voiceCallInfo = responseData['voice_call'];
    assert(voiceCallInfo['service'] == 'agora');
    _agoraClientAppKey = voiceCallInfo['key'];

    _biliSess = responseData['bilibili_sess'];

    final alistData = responseData['alist'];
    _aListClientInfo = alistData == null
        ? null
        : AListClientInfo(
            host: alistData['host'],
            token: alistData['token'],
          );
  }

  late final ChatClientInfo _chatClientInfo;
  ChatClientInfo get chatClientInfo => _chatClientInfo;

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

  Future<Uint8List> getAlistThumb({
    required String path,
    required String alistToken,
  }) async {
    final response = await http.get(
      _host.resolve('alist/thumb?path=${Uri.encodeFull(path)}'),
      headers: {'alist-token': alistToken},
    );
    return response.bodyBytes;
  }

  Future<http.Response> get(String reference) {
    return http.get(
      _host.resolve(reference),
      headers: {'Authorization': _userToken},
    );
  }

  Future<http.Response> post(String reference, Object? body) {
    return http.post(
      _host.resolve(reference),
      headers: {
        'Authorization': _userToken,
        'content-type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }
}
