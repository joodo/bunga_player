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
}
