import 'dart:io';

class LocalVideoProxy {
  HttpServer? _server;
  final _httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) =>
        true;

  // To handle relative paths in m3u8, we store the base remote URL
  String? _baseRemoteUrl;

  Future<String> startProxy(
    String remoteUrl,
    Map<String, String>? headers,
    String? proxy,
  ) async {
    _setProxy(proxy);

    await stop();
    _server = await HttpServer.bind('127.0.0.1', 0);

    // Parse the base URL (e.g., http://site.com/path/to/video.m3u8 -> http://site.com/path/to/)
    final uri = Uri.parse(remoteUrl);
    _baseRemoteUrl = uri.resolve('.').toString();

    _server!.listen((HttpRequest request) async {
      try {
        Uri targetUri;
        if (request.uri.path == '/proxy_video') {
          targetUri = Uri.parse(remoteUrl);
        } else {
          // Resolve relative paths (for .ts files or sub-m3u8)
          targetUri = Uri.parse(
            _baseRemoteUrl!,
          ).resolve(request.uri.path.substring(1));
        }
        final clientReq = await _httpClient.getUrl(targetUri);

        // Forward headers from agora
        headers?.forEach((key, value) => clientReq.headers.set(key, value));

        // Handle Range requests for MP4 seeking
        String? range = request.headers.value('range');
        if (range != null) clientReq.headers.set('range', range);

        final clientRes = await clientReq.close();

        request.response.statusCode = clientRes.statusCode;

        // Headers
        clientRes.headers.forEach((name, values) {
          final String n = name.toLowerCase();

          if (n == 'transfer-encoding' ||
              n == 'content-encoding' ||
              n == 'connection' ||
              n == 'content-disposition') {
            return;
          }

          if (n == 'etag') {
            String etag = values.join(',');
            request.response.headers.set(
              'etag',
              etag.startsWith('"') ? etag : '"$etag"',
            );
          } else {
            request.response.headers.set(name, values.join(','));
          }
        });

        request.response.headers.set('Accept-Ranges', 'bytes');
        request.response.headers.set('Access-Control-Allow-Origin', '*');
        request.response.headers.set('Access-Control-Allow-Headers', '*');
        request.response.headers.set('Server', 'BungaPlayerProxy/1.0');

        await request.response.addStream(clientRes);
        await request.response.close();
      } catch (e) {
        request.response.close();
      }
    });

    return "http://127.0.0.1:${_server!.port}/proxy_video";
  }

  Future<void> stop() async => await _server?.close(force: true);

  void _setProxy(String? proxy) {
    if (proxy != null) {
      _httpClient.findProxy = (uri) {
        return "PROXY $proxy";
      };
    } else {
      _httpClient.findProxy = (uri) {
        return "DIRECT";
      };
    }
  }
}
