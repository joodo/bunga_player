import 'dart:io';
import 'package:bunga_player/network/video_source.dart';
import 'package:http/http.dart' as http;

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';
import 'package:bunga_player/utils/models/network_progress.dart';

typedef SourceInfo = ({String location, int bps});

class NetworkService {
  NetworkService() {
    HttpOverrides.global = _BungaHttpOverrides(_findProxy);
  }

  String? _proxyHost = getIt<Preferences>().get<String>('proxy');
  void setProxy(String? host) {
    _proxyHost = host;
  }

  String _findProxy(Uri uri) {
    if (_proxyHost == null) return 'DIRECT';
    return 'PROXY $_proxyHost';
  }

  Future<SourceInfo> sourceInfo(
    String source, [
    Map<String, String>? headers,
  ]) async {
    late final String location;
    late final int bps;

    final s = VideoSource(Uri.parse(source), headers: headers);

    await Future.wait([
      s.getIpLocation().then((value) => location = value),
      s.estimateSpeed().then((value) => bps = value),
    ]);

    return (location: location, bps: bps);
  }

  Stream<RequestProgress> downloadFile(String url, String path) async* {
    final response = await http.Client().send(
      http.Request('GET', Uri.parse(url)),
    );
    if (!response.isSuccess) {
      throw Exception(response.statusCode);
    }

    final totalBytes = response.contentLength ?? 0;
    final List<int> bytes = [];
    int currentBytes = 0;
    await for (final value in response.stream) {
      bytes.addAll(value);
      currentBytes += value.length;
      yield RequestProgress(total: totalBytes, current: currentBytes);
    }

    await File(path).writeAsBytes(bytes);
    logger.i('Network: $path download finished from $url');
  }
}

class _BungaHttpOverrides extends HttpOverrides {
  _BungaHttpOverrides(this._findProxy);
  final String Function(Uri uri) _findProxy;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)..findProxy = _findProxy;

    return client;
  }
}
