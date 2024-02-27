import 'dart:convert';
import 'dart:io';

import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:http/http.dart' as http;

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

  Future<(String location, Duration latency)> ipInfo(String source) async {
    final uri = Uri.parse(source);
    final ping = Ping(uri.host, count: 5);
    final result = await ping.stream.first;
    final latency = result.response!.time!;

    final ip = result.response!.ip!;
    final response = await http.get(
      Uri.parse(
          'https://opendata.baidu.com/api.php?query=$ip&co=&resource_id=6006&oe=utf8'),
    );
    final location = jsonDecode(response.body)['data'][0]['location'] as String;

    return (location, latency);
  }
}

class _BungaHttpOverrides extends HttpOverrides {
  _BungaHttpOverrides(this._findProxy);
  final String Function(Uri uri) _findProxy;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..findProxy = _findProxy;
  }
}
