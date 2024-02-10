import 'dart:convert';

import 'package:bunga_player/models/alist/file_info.dart';
import 'package:bunga_player/models/alist/search_result.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:http/http.dart' as http;

class AList {
  Uri? _host;
  get host => _host;
  String? _token;
  get token => _token;

  AList() {
    _getToken();
  }

  Future<void> _getToken() async {
    final response = await getService<Bunga>().getAListToken();
    _host = Uri.parse(response.$1);
    _token = response.$2;
    logger.i('Alist token got successfully.');
  }

  late final _header = {
    'Authorization': _token!,
    'content-type': 'application/json',
  };

  Future<List<AListFileInfo>> list(String path, {bool refresh = false}) async {
    assert(_host != null && _token != null);

    final response = await http.post(
      _host!.resolve('fs/list'),
      headers: _header,
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
    assert(_host != null && _token != null);

    final response = await http.post(
      _host!.resolve('fs/search'),
      headers: _header,
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
    assert(_host != null && _token != null);

    final response = await http.post(
      _host!.resolve('fs/get'),
      headers: _header,
      body: {'path': path},
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
}
