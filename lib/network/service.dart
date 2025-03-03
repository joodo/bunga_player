import 'dart:convert';
import 'dart:io';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';
import 'package:bunga_player/utils/models/network_progress.dart';
import 'package:http/http.dart' as http;

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

    await Future.wait([
      _getUrlIpLocation(source).then((value) => location = value),
      _estimateDownloadSpeed(source, headers).then((value) => bps = value),
    ]);

    return (location: location, bps: bps);
  }

  Future<int> _estimateDownloadSpeed(
    String url,
    Map<String, String>? headers,
  ) async {
    const testMb = 2; // download 500 kb for test

    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });
    final response = await request.close().timeout(const Duration(seconds: 5));

    int downloadedBytes = 0;
    final stopwatch = Stopwatch()..start();

    await for (final chunk in response) {
      downloadedBytes += chunk.length;

      if (downloadedBytes >= testMb * 1024 * 1024) {
        stopwatch.stop();
        break;
      }
    }
    client.close();

    final seconds = stopwatch.elapsedMilliseconds / 1000;
    final bytesPerSecond = downloadedBytes / seconds;
    return bytesPerSecond.toInt();
  }

  Future<String> _getUrlIpLocation(String url) async {
    final uri = Uri.parse(url);
    final host = uri.host;

    final addresses = await InternetAddress.lookup(host);
    final ip =
        addresses.firstWhere((e) => e.type == InternetAddressType.IPv4).address;

    final response = await http.get(
      Uri.parse(
          'https://opendata.baidu.com/api.php?query=$ip&co=&resource_id=6006&oe=utf8'),
    );
    final location = jsonDecode(response.body)['data'][0]['location'] as String;
    return location;
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
