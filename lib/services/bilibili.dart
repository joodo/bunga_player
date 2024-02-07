import 'dart:convert';

import 'package:bunga_player/models/playing/online_video_entry.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:http/http.dart' as http;

class BiliVideoEntry extends OnlineVideoEntry {
  static const hashPrefix = 'bilivideo';

  final String bvid;
  final int p;

  late final String cid;
  late final int totalP;
  late final bool isHD;

  BiliVideoEntry({required this.bvid, this.p = 1});

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch() async {
    logger.i('Bili video: start fetch BV=$bvid, p=$p');

    final getSess = getService<Bunga>().getBiliSess;
    String? sess;
    await Future.wait([
      () async {
        // fetch cookie
        sess = await getSess();
        isHD = sess != null;
        if (!isHD) {
          // TODO: showToast
          logger.w('Bilibili: Cookie of serverless funtion outdated');
        }
      }(),
      () async {
        // fetch video info
        final response = await http.get(Uri.parse(
            'https://api.bilibili.com/x/web-interface/view?bvid=$bvid'));
        final responseData = jsonDecode(response.body);
        if (responseData['code'] != 0) {
          throw 'Cannot get video info';
        }

        pic = responseData['data']['pic'];

        final List pages = responseData['data']['pages'];
        totalP = pages.length;
        title = totalP > 1
            ? '${responseData['data']['title']} [$p/$totalP]'
            : responseData['data']['title'];
        cid = pages[p - 1]['cid'].toString();
      }(),
    ]);

    // fetch video url with cookie and video info
    final response = await http.get(
      Uri.parse(
          'https://api.bilibili.com/x/player/playurl?bvid=$bvid&cid=$cid&qn=112'),
      headers: sess == null ? null : {"Cookie": 'SESSDATA=$sess'},
    );
    final responseData = jsonDecode(response.body);
    if (responseData['code'] == 0) {
      final durl = responseData['data']['durl'][0];
      sources = VideoSources(video: [
        durl['url'],
        ...durl['backup_url'] ?? [],
      ]);
    } else {
      // can't get url from api.bilibili.com
      logger.w('Cannot fetch by api');
      final response = await http.get(
        Uri.parse('https://www.bilibili.com/video/BV$bvid/?p=$p'),
        headers: sess == null ? null : {'Cookie': 'SESSDATA=$sess'},
      );

      final regex =
          RegExp(r'<script>window.__playinfo__=(?<json>\{.*?\})</script>');
      final match = regex.firstMatch(response.body);
      if (match == null) throw 'Cannot fetch video';

      final playinfo = jsonDecode(match.namedGroup('json')!);
      final videoinfo = playinfo['data']['dash']['video'] as List;
      final autioinfo = playinfo['data']['dash']['audio'] as List;
      sources = VideoSources(
        video: videoinfo.map((e) => e['baseUrl'] as String).toList(),
        audio: autioinfo.map((e) => e['baseUrl'] as String).toList(),
      );
    }

    _isFetched = true;
  }

  @override
  String get hash => '$hashPrefix-$bvid-$p';

  factory BiliVideoEntry.fromHash(String hash) {
    final splits = hash.split('-');
    assert(splits.first == hashPrefix);
    return BiliVideoEntry(bvid: splits[1], p: int.parse(splits[2]));
  }
}

class BiliBungumiEntry extends OnlineVideoEntry {
  static const hashPrefix = 'bilibungumi';

  final int epid;

  BiliBungumiEntry({required this.epid});

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch() async {
    logger.i('Bili bungumi: start fetch epid=$epid');

    final getSess = getService<Bunga>().getBiliSess;
    late final String? sess;
    await Future.wait([
      () async {
        // fetch cookie
        sess = await getSess();
      }(),
      () async {
        // fetch video info
        final response = await http.get(Uri.parse(
            'https://api.bilibili.com/pgc/view/web/season?ep_id=$epid'));
        final responseData =
            jsonDecode(utf8.decoder.convert(response.bodyBytes));
        if (responseData['code'] != 0) {
          throw 'Cannot get video info';
        }

        final episodes = responseData['result']['episodes'] as List;
        bool episodeFound = false;
        for (var episode in episodes) {
          if (episode['id'] == epid) {
            pic = episode['cover'];
            title = episode['share_copy'];
            episodeFound = true;
            break;
          }
        }
        if (!episodeFound) {
          throw 'Cannot found episode info';
        }
      }(),
    ]);

    if (sess == null) {
      throw 'No sess data in Bunga server, cannot get bungami video';
    }

    // fetch video url with cookie and epid
    final response = await http.get(
      Uri.parse(
          'https://api.bilibili.com/pgc/player/web/playurl?ep_id=$epid&qn=112'),
      headers: {
        'Cookie': 'SESSDATA=$sess',
        'Referer': 'https://www.bilibili.com',
      },
    );
    final responseData = jsonDecode(response.body);
    if (responseData['code'] != 0) throw 'Failed to fetch durls';

    final durl = responseData['result']['durl'][0];
    sources = VideoSources(video: [
      durl['url'],
      ...durl['backup_url'] ?? [],
    ]);

    _isFetched = true;
  }

  @override
  String get hash => '$hashPrefix-$epid';

  factory BiliBungumiEntry.fromHash(String hash) {
    final splits = hash.split('-');
    assert(splits.first == hashPrefix);
    return BiliBungumiEntry(epid: int.parse(splits[1]));
  }
}

class Bilibili {
  final getSess = getService<Bunga>().getBiliSess;

  Bilibili() {
    // Register fromHash factory method
    OnlineVideoEntry.fromHashMap[BiliVideoEntry.hashPrefix] =
        BiliVideoEntry.fromHash;
    OnlineVideoEntry.fromHashMap[BiliBungumiEntry.hashPrefix] =
        BiliBungumiEntry.fromHash;
  }

  Future<OnlineVideoEntry> getEntryFromUri(Uri uri) async {
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
        throw 'Unknown host: ${uri.host}';
    }
  }
}
