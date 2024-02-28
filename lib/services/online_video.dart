import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:http/http.dart' as http;

class SupportSite {
  final String name;
  final String url;

  SupportSite({required this.name, required this.url});
}

class OnlineVideoService {
  OnlineVideoService() {
    _getSupportSites();
  }

  late final List<SupportSite> supportSites;
  Future<void> _getSupportSites() async {
    supportSites = (await getIt<Bunga>().getSupportSites()).toList();
    logger.i('Support sites fetched.');
  }

  late String? biliSess;
  Future<void> fetchSess() async {
    if (biliSess != null) return;
    biliSess = await getIt<Bunga>().getBiliSess();
    logger.i('Bilibili sess fetched');
  }

  Future<VideoEntry> getEntryFromUri(Uri uri) async {
    switch (uri.host) {
      case 'b23.tv':
        final req = http.Request("Get", uri)..followRedirects = false;
        final baseClient = http.Client();
        final response = await baseClient.send(req);
        final redirectUri = Uri.parse(response.headers['location']!);
        logger.i('Bili video: redirect to $redirectUri');
        return getEntryFromUri(redirectUri);

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
            final epString = uri.pathSegments[2].substring(2);
            final epid = int.parse(epString);
            return BiliBungumiEntry(epid: epid);
          default:
            throw 'Unknown url path: ${uri.path}';
        }

      default:
        final entry = M3u8Entry(path: uri.toString());
        // prefetch in case site not support
        await entry.fetch();
        return entry;
    }
  }
}
