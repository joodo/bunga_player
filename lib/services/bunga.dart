import 'dart:convert';

import 'package:bunga_player/services/online_video.dart';
import 'package:bunga_player/utils/http_response.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:http/http.dart' as http;

class NeedEpisodeIndexException implements Exception {
  final Iterable<String> episodeNames;
  NeedEpisodeIndexException(this.episodeNames);
}

class Bunga {
  final Uri _host;
  Bunga(String host) : _host = Uri.parse(host);

  Future<Map<String, dynamic>> getAppKey() async {
    final response = await http.get(_host.resolve('auth/app-key'));
    if (!response.isSuccess) throw response.body;
    return jsonDecode(response.body);
  }

  Future<(String host, String token)> getAListToken() async {
    final response = await http.get(_host.resolve('auth/alist'));
    if (!response.isSuccess) throw response.body;
    final data = jsonDecode(response.body);
    return (data['host'] as String, data['token'] as String);
  }

  String? _userToken;
  Future<String> userLogin(String id) async {
    final response = await http.post(
      _host.resolve('auth/login'),
      body: {'user_id': id},
    );

    if (!response.isSuccess) {
      throw Exception('Get token failed: ${response.body}');
    }
    _userToken = jsonDecode(response.body);
    return _userToken!;
  }

  Future<String?> getBiliSess() async {
    final response = await http.get(
      _host.resolve('bilibili/sess'),
      headers: {'Authorization': _userToken ?? ''},
    );
    if (!response.isSuccess) {
      throw Exception('Bilibili sess fetched failed: ${response.body}');
    }
    return response.body;
  }

  Future<Map> parseVideoUrl(String url) async {
    final response = await http.post(
      _host.resolve('video-parse'),
      headers: {'Authorization': _userToken ?? ''},
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

  Future<(String location, Duration latency)> fetchSourcesInfo(
      String source) async {
    final uri = Uri.parse(source);
    final ping = Ping(uri.host, count: 5);
    final result = await ping.stream.first;
    final latency = result.response!.time!;

    final ip = result.response!.ip!;
    final response = await http.get(
      Uri.parse(
          'https://opendata.baidu.com/api.php?query=$ip&co=&resource_id=6006&oe=utf8'),
    );
    final location = jsonDecode(response.body)['data'][0]['location'] as String;

    return (location, latency);
  }
}
