import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/clients/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:http/http.dart' as http;

class SupportSite {
  final String name;
  final String url;

  SupportSite({required this.name, required this.url});
}

class OnlineVideoClient {
  final BungaClient _bungaClient;
  OnlineVideoClient(this._bungaClient) {
    _getSupportSites();
  }

  late final List<SupportSite> supportSites;
  Future<void> _getSupportSites() async {
    supportSites = (await _bungaClient.getSupportSites()).toList();
    logger.i('Support sites fetched.');
  }

  late final String? biliSess = _bungaClient.biliSess;

  Future<VideoEntry> getEntryFromUri(Uri uri) async {
    switch (uri.host) {
      case 'b23.tv':
        final req = http.Request("Get", uri)..followRedirects = false;
        final baseClient = http.Client();
        final response = await baseClient.send(req);
        final redirectUri = Uri.parse(response.headers['location']!);
        logger.i('Bili video: redirect to $redirectUri');
        return getEntryFromUri(redirectUri);

      // TODO: deal with m.bilibili.tv
      case 'www.bilibili.com':
        switch (uri.pathSegments[0]) {
          case 'video':
            final regex = RegExp(r'\/BV(?<bvid>[A-Za-z0-9]*)\/?');

            final match = regex.firstMatch(uri.path);
            if (match == null) throw 'No bv found in url';
            final bvid = match.namedGroup('bvid')!;

            final p = int.parse(uri.queryParameters['p'] ?? '1');
            return BiliVideoEntry(bvid: bvid, p: p);
          case 'bangumi':
            final idString = uri.pathSegments[2];
            if (idString.startsWith('ep')) {
              final epid = int.parse(idString.substring(2));
              return BiliBungumiEntry(epid: epid);
            } else if (idString.startsWith('ss')) {
              final sessionId = idString.substring(2);
              return await BiliBungumiEntry.parseSessionId(sessionId);
            } else {
              throw Exception('Bilibili: unknown bangumi id: $idString');
            }
          default:
            throw 'Unknown url path: ${uri.path}';
        }

      default:
        final entry = M3u8Entry(path: uri.toString());
        return entry;
    }
  }
}
