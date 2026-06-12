import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '/services/logger.dart';

class LocalVideoProxy {
  LocalVideoProxy() {
    _cleanOldProxyCaches();
  }

  Future<void> _cleanOldProxyCaches() async {
    try {
      final tempDir = await getApplicationCacheDirectory();

      if (await tempDir.exists()) {
        await for (final entity in tempDir.list(
          recursive: false,
          followLinks: false,
        )) {
          if (entity is Directory &&
              entity.path.contains('bunga_proxy_cache_')) {
            await entity.delete(recursive: true);
          }
        }
      }
    } catch (e) {
      logger.w('Failed to clean playing cache: $e');
    }
  }

  HttpServer? _server;
  Directory? _cacheDir;
  final Map<String, _CacheEntry> _cacheEntries = {};

  final _httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) =>
        true;

  Future<String> startProxy(
    String remoteUrl,
    Map<String, String>? headers,
    String? proxy,
  ) async {
    _setProxy(proxy);

    await stop();
    _server = await HttpServer.bind('127.0.0.1', 0);

    final tempDir = await getApplicationCacheDirectory();
    _cacheDir = await tempDir.createTemp('bunga_proxy_cache_');

    final uri = Uri.parse(remoteUrl);
    // handle relative paths in m3u8
    String? baseRemoteUrl = uri.resolve('.').toString();

    _server!.listen((HttpRequest request) async {
      try {
        Uri targetUri;
        if (request.uri.path == '/proxy_video') {
          targetUri = Uri.parse(remoteUrl);
        } else {
          // Keep query parameters while resolving relative paths (HLS URLs may carry auth tokens).
          // if pathSegments more than 1, maybe it's a m3u8 redirect
          // else it's a ts file
          final relativePath = request.uri.pathSegments.length > 1
              ? request.uri.path
              : request.uri.path.substring(1);

          final relativeUri = Uri(
            path: relativePath,
            query: request.uri.hasQuery ? request.uri.query : null,
          );
          targetUri = Uri.parse(baseRemoteUrl!).resolveUri(relativeUri);
        }

        final cacheKey = targetUri.toString();
        final cacheEntry = _cacheEntries.putIfAbsent(
          cacheKey,
          () => _CacheEntry(
            key: cacheKey,
            filePath:
                '${_cacheDir!.path}/${_cacheFileNameForUrl(cacheKey)}.cache',
          ),
        );

        final requestedRange = _RangeRequest.parse(
          request.headers.value('range'),
        );

        if (await _tryServeFromCache(request, cacheEntry, requestedRange)) {
          return;
        }

        final clientReq = await _httpClient.openUrl(request.method, targetUri);
        headers?.forEach((key, value) => clientReq.headers.set(key, value));

        // Handle Range requests for MP4 seeking
        final range = request.headers.value('range');
        if (range != null) clientReq.headers.set('range', range);

        final clientRes = await clientReq.close();
        request.response.statusCode = clientRes.statusCode;

        if (clientRes.redirects.isNotEmpty) {
          final newUri = clientRes.redirects.last.location;
          if (newUri.isAbsolute) {
            baseRemoteUrl = newUri.resolve('.').toString();
          }
        }

        // Bypass m3u8 file
        final contentType =
            clientRes.headers.contentType?.value.toLowerCase() ?? '';
        if (contentType.contains('vnd.apple.mpegurl') ||
            contentType.contains('x-mpegurl')) {
          request.response.headers.contentType = ContentType(
            'application',
            'vnd.apple.mpegurl',
          );
          request.response.headers.set('Access-Control-Allow-Origin', '*');
          await clientRes.pipe(request.response);
          return;
        }

        _copyResponseHeaders(clientRes.headers, request.response.headers);
        //_applyProxyHeaders(request.response.headers);
        request.response.statusCode = clientRes.statusCode;

        final shouldAppend = _canAppendToCache(
          requestRange: requestedRange,
          upstreamStatusCode: clientRes.statusCode,
          upstreamContentRange: clientRes.headers.value('content-range'),
          entry: cacheEntry,
        );

        IOSink? sink;
        var bytesWritten = 0;
        if (shouldAppend) {
          final file = File(cacheEntry.filePath);
          if (!await file.exists()) {
            await file.create(recursive: true);
          }
          sink = file.openWrite(mode: FileMode.append);
        }

        await for (final chunk in clientRes) {
          if (sink != null) {
            sink.add(chunk);
            bytesWritten += chunk.length;
          }
          request.response.add(chunk);
        }

        if (sink != null) {
          await sink.flush();
          await sink.close();
          cacheEntry.cachedBytes += bytesWritten;
          final totalBytes = _parseTotalBytes(
            contentRange: clientRes.headers.value('content-range'),
            contentLength: clientRes.headers.contentLength,
            statusCode: clientRes.statusCode,
            requestedRange: requestedRange,
          );
          if (totalBytes != null) {
            cacheEntry.totalBytes = totalBytes;
          }
        }

        await request.response.close();
      } catch (e) {
        request.response.close();
      }
    });

    final r = "http://127.0.0.1:${_server!.port}/proxy_video";
    return r;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;

    final cacheDir = _cacheDir;
    _cacheDir = null;
    _cacheEntries.clear();

    if (cacheDir != null && await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

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

  Future<bool> _tryServeFromCache(
    HttpRequest request,
    _CacheEntry entry,
    _RangeRequest? requestedRange,
  ) async {
    if (entry.cachedBytes <= 0) return false;

    final file = File(entry.filePath);
    if (!await file.exists()) return false;

    if (requestedRange == null) {
      if (!entry.isComplete) return false;

      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentLength =
          entry.totalBytes ?? entry.cachedBytes;
      request.response.headers.contentType = ContentType.binary;
      request.response.headers.set('Accept-Ranges', 'bytes');
      _applyProxyHeaders(request.response.headers);
      await request.response.addStream(file.openRead());
      await request.response.close();
      return true;
    }

    if (requestedRange.start == null) {
      return false;
    }

    final start = requestedRange.start!;
    if (start >= entry.cachedBytes) return false;

    int? end = requestedRange.end;
    final cachedEnd = entry.cachedBytes - 1;

    if (end != null && end > cachedEnd) {
      return false;
    }

    end ??= (entry.totalBytes != null) ? entry.totalBytes! - 1 : cachedEnd;
    if (end > cachedEnd) {
      return false;
    }

    final contentLength = end - start + 1;
    request.response.statusCode = HttpStatus.partialContent;
    request.response.headers.contentType = ContentType.binary;
    request.response.headers.contentLength = contentLength;
    request.response.headers.set('Accept-Ranges', 'bytes');
    if (entry.totalBytes != null) {
      request.response.headers.set(
        'Content-Range',
        'bytes $start-$end/${entry.totalBytes}',
      );
    }
    _applyProxyHeaders(request.response.headers);
    await request.response.addStream(file.openRead(start, end + 1));
    await request.response.close();
    return true;
  }

  bool _canAppendToCache({
    required _RangeRequest? requestRange,
    required int upstreamStatusCode,
    required String? upstreamContentRange,
    required _CacheEntry entry,
  }) {
    if (upstreamStatusCode != HttpStatus.ok &&
        upstreamStatusCode != HttpStatus.partialContent) {
      return false;
    }

    if (upstreamStatusCode == HttpStatus.ok) {
      return entry.cachedBytes == 0;
    }

    final upstreamRange = _ContentRange.parse(upstreamContentRange);
    if (upstreamRange == null) return false;

    final requestStart = requestRange?.start;
    final start = requestStart ?? upstreamRange.start;
    return start == entry.cachedBytes;
  }

  int? _parseTotalBytes({
    required String? contentRange,
    required int contentLength,
    required int statusCode,
    required _RangeRequest? requestedRange,
  }) {
    final parsedRange = _ContentRange.parse(contentRange);
    if (parsedRange?.total != null) {
      return parsedRange!.total;
    }

    if (statusCode == HttpStatus.ok && contentLength >= 0) {
      return contentLength;
    }

    if (statusCode == HttpStatus.partialContent && contentLength >= 0) {
      final start = requestedRange?.start;
      if (start != null) {
        return start + contentLength;
      }
    }

    return null;
  }

  void _copyResponseHeaders(HttpHeaders from, HttpHeaders to) {
    from.forEach((name, values) {
      final n = name.toLowerCase();

      switch (n) {
        case 'transfer-encoding' ||
            'content-encoding' ||
            'connection' ||
            'content-disposition' ||
            'x-content-type-options' ||
            'x-frame-options' ||
            'x-xss-protection':
          break;

        case 'etag':
          final etag = values.join(',');
          to.set('etag', etag.startsWith('"') ? etag : '"$etag"');

        default:
          to.set(name, values.join(','));
      }
    });
  }

  void _applyProxyHeaders(HttpHeaders headers) {
    headers.set('Accept-Ranges', 'bytes');
    headers.set('Access-Control-Allow-Origin', '*');
    headers.set('Access-Control-Allow-Headers', '*');
    headers.set('Server', 'BungaPlayerProxy/1.0');
  }

  String _cacheFileNameForUrl(String url) {
    final hash = url.hashCode.toUnsigned(32).toRadixString(16);
    return 'entry_$hash';
  }
}

class _CacheEntry {
  _CacheEntry({required this.key, required this.filePath});

  final String key;
  final String filePath;
  int cachedBytes = 0;
  int? totalBytes;

  bool get isComplete => totalBytes != null && cachedBytes >= totalBytes!;
}

class _RangeRequest {
  _RangeRequest({required this.start, required this.end});

  final int? start;
  final int? end;

  static _RangeRequest? parse(String? header) {
    if (header == null) return null;
    final match = RegExp(r'^bytes=(\d*)-(\d*)$').firstMatch(header.trim());
    if (match == null) return null;

    final startText = match.group(1);
    final endText = match.group(2);
    final start = (startText == null || startText.isEmpty)
        ? null
        : int.tryParse(startText);
    final end = (endText == null || endText.isEmpty)
        ? null
        : int.tryParse(endText);
    return _RangeRequest(start: start, end: end);
  }
}

class _ContentRange {
  _ContentRange({required this.start, required this.end, required this.total});

  final int start;
  final int end;
  final int? total;

  static _ContentRange? parse(String? header) {
    if (header == null) return null;
    final match = RegExp(
      r'^bytes\s+(\d+)-(\d+)/(\d+|\*)$',
    ).firstMatch(header.trim());
    if (match == null) return null;

    final start = int.tryParse(match.group(1) ?? '');
    final end = int.tryParse(match.group(2) ?? '');
    final totalText = match.group(3);
    final total = (totalText == null || totalText == '*')
        ? null
        : int.tryParse(totalText);

    if (start == null || end == null) return null;
    return _ContentRange(start: start, end: end, total: total);
  }
}
