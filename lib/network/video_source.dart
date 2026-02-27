import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:m3u_nullsafe/m3u_nullsafe.dart';

class VideoSource {
  static const testMb = 3;

  final Uri url;
  final Map<String, String>? headers;

  static Future<VideoSource> create(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    if (!await _isM3U8(url, headers)) return VideoSource._(url, headers);

    final videoUrl = await _getTestSegmentUrl(url, headers);
    if (videoUrl == null) throw Exception('Parse m3u8 file failed.');

    return VideoSource._(videoUrl, headers);
  }

  const VideoSource._(this.url, this.headers);

  Future<int> estimateSpeed() async {
    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      final request = await client.getUrl(url);
      headers?.forEach((key, value) => request.headers.set(key, value));

      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );

      int downloadedBytes = 0;
      final stopwatch = Stopwatch();
      final completer = Completer<int>();

      StreamSubscription<List<int>>? subscription;

      subscription = response.listen(
        (chunk) {
          if (downloadedBytes == 0) stopwatch.start();

          downloadedBytes += chunk.length;

          if (downloadedBytes >= testMb * 1024 * 1024) {
            stopwatch.stop();
            subscription?.cancel();
            if (!completer.isCompleted) completer.complete(downloadedBytes);
          }
        },
        onError: (e) {
          stopwatch.stop();
          if (!completer.isCompleted) completer.completeError(e);
        },
        onDone: () {
          stopwatch.stop();
          if (!completer.isCompleted) completer.complete(downloadedBytes);
        },
        cancelOnError: true,
      );

      await completer.future.timeout(Duration(seconds: 5));

      final seconds = stopwatch.elapsedMilliseconds / 1000;
      if (seconds == 0) return 0;

      return (downloadedBytes / seconds).toInt();
    } catch (e) {
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  Future<String> getIpLocation() async {
    final host = url.host;
    final addresses = await InternetAddress.lookup(host);
    final ip = addresses
        .firstWhere((e) => e.type == InternetAddressType.IPv4)
        .address;

    final response = await http.get(
      Uri.parse(
        'https://opendata.baidu.com/api.php?query=$ip&co=&resource_id=6006&oe=utf8',
      ),
    );
    final location = jsonDecode(response.body)['data'][0]['location'] as String;
    return location;
  }

  static Future<bool> _isM3U8(Uri url, Map<String, String>? headers) async {
    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final ioClient = IOClient(httpClient);

    final response = await ioClient.head(url, headers: headers);

    String? contentType = response.headers['content-type']?.toLowerCase();

    if (contentType == null) return false;

    if (contentType.contains('application/vnd.apple.mpegurl') ||
        contentType.contains('application/x-mpegurl') ||
        contentType.contains('text/html')) {
      return true;
    }

    return false;
  }

  static Future<Uri?> _getTestSegmentUrl(
    Uri m3u8Url,
    Map<String, String>? headers,
  ) async {
    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final ioClient = IOClient(httpClient);
    final response = await ioClient.get(m3u8Url, headers: headers);

    if (response.statusCode != 200) return null;

    final m3u = await M3uParser.parse(response.body);

    if (m3u.isEmpty) return null;

    final isMaster = m3u.any(
      (entry) => entry.attributes.containsKey('BANDWIDTH'),
    );

    if (isMaster) {
      final sortedEntries = m3u.toList()
        ..sort((a, b) {
          int bwA = int.tryParse(a.attributes['BANDWIDTH'] ?? '0') ?? 0;
          int bwB = int.tryParse(b.attributes['BANDWIDTH'] ?? '0') ?? 0;
          return bwA.compareTo(bwB);
        });

      final targetStream = sortedEntries[sortedEntries.length ~/ 2];
      final subUrl = m3u8Url.resolve(targetStream.link);

      return _getTestSegmentUrl(subUrl, headers);
    } else {
      if (m3u.length > 2) {
        return m3u8Url.resolve(m3u[1].link);
      } else if (m3u.isNotEmpty) {
        return m3u8Url.resolve(m3u[0].link);
      } else {
        return null;
      }
    }
  }
}
