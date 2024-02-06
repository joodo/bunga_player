import 'dart:convert';

import 'package:bunga_player/models/alist/file_info.dart';
import 'package:bunga_player/models/alist/search_result.dart';
import 'package:http/http.dart' as http;

class AList {
  final host = Uri.parse('https://alist-joodo.koyeb.app/api/');
  final token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwicHdkX3RzIjoxNzA3MjAwMzI1LCJleHAiOjE3MDczNzMxNDQsIm5iZiI6MTcwNzIwMDM0NCwiaWF0IjoxNzA3MjAwMzQ0fQ._5m_IxVBSlEIOF3UsEZX_JfcdGQWN8QCsKIlBK-fiqk';

  Future<List<AListFileInfo>> list(String path) async {
    final response = await http.post(
      host.resolve('fs/list'),
      headers: {'Authorization': token},
      body: {'path': path},
    );

    if (!_requestSuccess(response)) {
      throw Exception('AList: list directory $path failed: ${response.body}');
    }

    final infos = jsonDecode(response.body)['data']['content'] as List;
    return infos
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
      headers: {
        'Authorization': token,
        'content-type': 'application/json',
      },
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

  bool _requestSuccess(http.Response response) {
    final code = jsonDecode(response.body)['code'] as int;
    return code ~/ 100 == 2;
  }
}
