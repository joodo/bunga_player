import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/file_info.dart';
import 'models/search_result.dart';

class AListClient {
  final Uri host;
  final String token;

  AListClient({
    required String host,
    required this.token,
  }) : host = Uri.parse(host);

  late final _headers = {
    'Authorization': token,
    'content-type': 'application/json',
  };

  Future<List<AListFileInfo>> list(String path, {bool refresh = false}) async {
    final response = await http.post(
      host.resolve('fs/list'),
      headers: _headers,
      body: jsonEncode({
        'path': path,
        if (refresh) 'refresh': true,
      }),
    );

    if (!_requestSuccess(response)) {
      throw Exception('AList: list directory $path failed: ${response.body}');
    }

    final infos = jsonDecode(response.body)['data']['content'];
    if (infos == null) return [];

    return (infos as List)
        .map((originValue) => AListFileInfo.fromJson(originValue))
        .toList()
      ..sort(
        (a, b) {
          return a.type.index != b.type.index
              ? a.type.index - b.type.index
              : a.name.compareTo(b.name);
        },
      );
  }

  Future<List<AListSearchResult>> search(String keywords) async {
    final response = await http.post(
      host.resolve('fs/search'),
      headers: _headers,
      body: jsonEncode({
        "parent": "/",
        "keywords": keywords,
        "scope": 0,
        "page": 1,
        "per_page": 1000,
      }),
    );

    if (!_requestSuccess(response)) {
      throw Exception(
          'AList: search keyword $keywords failed: ${response.body}');
    }

    final results = jsonDecode(response.body)['data']['content'] as List;
    return results
        .map((originValue) => AListSearchResult.fromJson(originValue))
        .toList();
  }

  Future<AListFileInfo> get(String path) async {
    final response = await http.post(
      host.resolve('fs/get'),
      headers: _headers,
      body: jsonEncode({'path': path}),
    );

    if (!_requestSuccess(response)) {
      throw Exception('AList: get file info failed: $path');
    }

    final data = jsonDecode(response.body)['data'];
    return AListFileInfo.fromJson(data);
  }

  bool _requestSuccess(http.Response response) {
    final code = jsonDecode(response.body)['code'] as int;
    return code ~/ 100 == 2;
  }

  @override
  String toString() {
    return 'host: $host, token: $token';
  }
}
