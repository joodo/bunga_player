import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';

import 'models.dart';

extension _AListInfo on BuildContext {
  AListInfo? get aListInfo => read<BungaClientInfo?>()?.alist;
}

extension _FromAListInfo on AListInfo {
  Uri resolveUri(String uri) => Uri.parse(host).resolve(uri);
  Map<String, String> get requestHeaders => {
        'Authorization': token,
        'content-type': 'application/json',
      };
}

extension _AListResponse on http.Response {
  bool get success {
    final code = jsonDecode(body)['code'] as int;
    return code ~/ 100 == 2;
  }
}

class ListIntent extends Intent {
  final String path;
  final bool refresh;
  const ListIntent(this.path, {this.refresh = false});
}

class ListAction extends ContextAction<ListIntent> {
  @override
  Future<List<AListFileDetail>> invoke(
    ListIntent intent, [
    BuildContext? context,
  ]) async {
    final info = context!.aListInfo!;
    final response = await http.post(
      info.resolveUri('/api/fs/list'),
      headers: info.requestHeaders,
      body: jsonEncode({
        'path': intent.path,
        if (intent.refresh) 'refresh': true,
      }),
    );

    if (!response.success) {
      throw Exception(
          'AList: list directory ${intent.path} failed: ${response.body}');
    }

    final infos = jsonDecode(response.body)['data']['content'];
    if (infos == null) return [];

    return (infos as List)
        .map((originValue) => AListFileDetail.fromJson(originValue))
        .toList()
      ..sort(
        (a, b) {
          return a.type.index != b.type.index
              ? a.type.index - b.type.index
              : a.name.compareTo(b.name);
        },
      );
  }

  @override
  bool isEnabled(ListIntent intent, [BuildContext? context]) {
    return context?.aListInfo != null;
  }
}

class SearchIntent extends Intent {
  final String keyword;
  const SearchIntent(this.keyword);
}

class SearchAction extends ContextAction<SearchIntent> {
  @override
  Future<List<AListSearchResult>> invoke(
    SearchIntent intent, [
    BuildContext? context,
  ]) async {
    final info = context!.aListInfo!;
    final response = await http.post(
      info.resolveUri('/api/fs/search'),
      headers: info.requestHeaders,
      body: jsonEncode({
        "parent": "/",
        "keywords": intent.keyword,
        "scope": 0,
        "page": 1,
        "per_page": 1000,
      }),
    );

    if (!response.success) {
      throw Exception(
          'AList: search keyword ${intent.keyword} failed: ${response.body}');
    }

    final results = jsonDecode(response.body)['data']['content'] as List;
    return results
        .map((originValue) => AListSearchResult.fromJson(originValue))
        .toList();
  }

  @override
  bool isEnabled(SearchIntent intent, [BuildContext? context]) {
    return context?.aListInfo != null;
  }
}

class GetIntent extends Intent {
  final String path;
  const GetIntent(this.path);
}

class GetAction extends ContextAction<GetIntent> {
  @override
  Future<AListFileDetail> invoke(GetIntent intent,
      [BuildContext? context]) async {
    final info = context!.aListInfo!;
    final response = await http.post(
      info.resolveUri('api/fs/get'),
      headers: info.requestHeaders,
      body: jsonEncode({'path': intent.path}),
    );

    if (!response.success) {
      throw Exception('AList: get file info failed: ${intent.path}');
    }

    final data = jsonDecode(response.body)['data'];
    return AListFileDetail.fromJson(data);
  }

  @override
  bool isEnabled(GetIntent intent, [BuildContext? context]) {
    return context?.aListInfo != null;
  }
}

class AListActions extends SingleChildStatelessWidget {
  const AListActions({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      actions: <Type, Action<Intent>>{
        ListIntent: ListAction(),
        SearchIntent: SearchAction(),
        GetIntent: GetAction(),
      },
      child: child ?? const SizedBox.shrink(),
    );
  }
}
