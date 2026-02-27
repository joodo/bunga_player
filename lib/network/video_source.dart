import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class VideoSource {
  static const testMb = 5;

  final Uri url;
  final Map<String, String>? headers;

  const VideoSource(this.url, {this.headers});

  Future<int> estimateSpeed() async {
    final client = HttpClient();
    final request = await client.getUrl(url);
    headers?.forEach((key, value) {
      request.headers.set(key, value);
    });
    final response = await request.close().timeout(const Duration(seconds: 5));

    int downloadedBytes = 0;
    final stopwatch = Stopwatch();

    bool firstByteGot = false;
    await for (final chunk in response) {
      if (!firstByteGot) stopwatch.start();

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
}
