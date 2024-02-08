import 'dart:convert';

import 'package:bunga_player/models/alist/file_info.dart';
import 'package:bunga_player/models/alist/search_result.dart';
import 'package:bunga_player/models/playing/online_video_entry.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:http/http.dart' as http;

class AListEntry extends OnlineVideoEntry {
  static String hashFromPath(String path) => path.hashCode.toRadixString(36);
  static const hashPrefix = 'alist';

  AListEntry({String? path, String? pathHash})
      : _path = path,
        _pathHash = pathHash {
    assert(_path != null || _pathHash != null,
        'One of "hash" and "hashPath" should not be null.');
  }

  String? _path;
  String? get path => _path;

  String? _pathHash;
  @override
  String get hash {
    _pathHash ??= hashFromPath(_path!);
    return '$hashPrefix-${_pathHash!}';
  }

  factory AListEntry.fromHash(String hash) {
    final splits = hash.split('-');
    assert(splits.first == hashPrefix);
    return AListEntry(pathHash: splits[1]);
  }

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch() async {
    if (_isFetched) return;
    logger.i('AList: start fetch video $_path');

    _path ??= await getService<Bunga>().getStringByHash(_pathHash!);

    final info = await getService<AList>().get(path!);
    title = info.name;
    pic = info.thumb;
    sources = VideoSources(video: [info.rawUrl!]);

    _isFetched = true;
  }
}

class AList {
  Uri? _host;
  get host => _host;
  String? _token;
  get token => _token;

  AList() {
    _getToken();
    OnlineVideoEntry.fromHashMap[AListEntry.hashPrefix] = AListEntry.fromHash;
  }

  Future<void> _getToken() async {
    final response = await getService<Bunga>().getAListToken();
    _host = Uri.parse(response.$1);
    _token = response.$2;
    logger.i('Alist token got successfully.');
  }

  Future<List<AListFileInfo>> list(String path, {bool refresh = false}) async {
    assert(_host != null && _token != null);

    final response = await http.post(
      _host!.resolve('fs/list'),
      headers: {
        'Authorization': _token!,
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'path': path,
        if (refresh) 'refresh': true,
      }),
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
    assert(_host != null && _token != null);

    final response = await http.post(
      _host!.resolve('fs/search'),
      headers: {
        'Authorization': _token!,
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

  Future<AListFileInfo> get(String path) async {
    assert(_host != null && _token != null);

    final response = await http.post(
      _host!.resolve('fs/get'),
      headers: {
        'Authorization': _token!,
      },
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
