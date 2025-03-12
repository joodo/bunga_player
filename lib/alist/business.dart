import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';

import 'models.dart';

typedef AlistRequestCallback = Future Function(
  String path,
  Map<String, Object?> payload,
);

@immutable
class ListIntent extends Intent {
  final String path;
  final bool refresh;
  const ListIntent(this.path, {this.refresh = false});
}

class ListAction extends ContextAction<ListIntent> {
  final AlistRequestCallback callback;
  ListAction({required this.callback});

  @override
  Future<List<AListFileDetail>> invoke(
    ListIntent intent, [
    BuildContext? context,
  ]) async {
    final data = await callback(
      '/api/fs/list',
      {
        'path': intent.path,
        if (intent.refresh) 'refresh': true,
      },
    );

    final infos = data['content'];
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
}

@immutable
class SearchIntent extends Intent {
  final String keyword;
  const SearchIntent(this.keyword);
}

class SearchAction extends ContextAction<SearchIntent> {
  final AlistRequestCallback callback;

  SearchAction({required this.callback});

  @override
  Future<List<AListSearchResult>> invoke(
    SearchIntent intent, [
    BuildContext? context,
  ]) async {
    final data = await callback(
      '/api/fs/search',
      {
        'parent': '/',
        'keywords': intent.keyword,
        'scope': 0,
        'page': 1,
        'per_page': 1000,
      },
    );

    final results = data['content'] as List;
    return results
        .map((originValue) => AListSearchResult.fromJson(originValue))
        .toList();
  }
}

@immutable
class GetIntent extends Intent {
  final String path;
  const GetIntent(this.path);
}

class GetAction extends ContextAction<GetIntent> {
  final AlistRequestCallback callback;

  GetAction({required this.callback});

  @override
  Future<AListFileDetail> invoke(GetIntent intent,
      [BuildContext? context]) async {
    final data = await callback(
      '/api/fs/get',
      {'path': intent.path},
    );

    return AListFileDetail.fromJson(data);
  }
}

class AListGlobalBusiness extends SingleChildStatelessWidget {
  const AListGlobalBusiness({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Consumer<BungaClientInfo?>(
      builder: (context, clientInfo, child) {
        final alistInfo = clientInfo?.alist;
        return child!.actions(
          actions: alistInfo == null ? {} : _createType(alistInfo),
        );
      },
      child: child,
    );
  }

  Map<Type, Action> _createType(AListInfo info) {
    final callback = _createCallback(info);
    return {
      ListIntent: ListAction(callback: callback),
      SearchIntent: SearchAction(callback: callback),
      GetIntent: GetAction(callback: callback),
    };
  }

  AlistRequestCallback _createCallback(AListInfo info) {
    return (String path, Map<String, Object?> payload) async {
      final url = Uri.parse(info.host).resolve(path);
      final header = {
        'Authorization': info.token,
        'content-type': 'application/json',
      };

      final response = await http.post(
        url,
        headers: header,
        body: jsonEncode(payload),
      );

      if (!response.isSuccess) {
        throw Exception('AList: get file info failed: $path');
      }

      return jsonDecode(response.body)['data'];
    };
  }
}
