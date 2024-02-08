import 'dart:convert';

import 'package:bunga_player/utils/http_response.dart';
import 'package:http/http.dart' as http;

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
    return response.statusCode == 200 ? response.body : null;
  }

  Future<String> getStringByHash(String hash) async {
    final response = await http.get(
      _host.resolve('utils/hash-string?hash=$hash'),
      headers: {'Authorization': _userToken ?? ''},
    );
    if (!response.isSuccess) {
      throw Exception('Fail to get string of hash $hash: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['data']['text'];
  }

  Future<void> setStringHash({required String text, required String hash}) {
    return http.post(
      _host.resolve('utils/hash-string'),
      headers: {'Authorization': _userToken ?? ''},
      body: {'hash': hash, 'text': text},
    );
  }
}
