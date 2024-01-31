import 'dart:convert';

import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:http/http.dart' as http;

typedef DURL = List<String>;

class VideoSources {
  final List<String> video;
  final List<String>? audio;

  VideoSources({required this.video, this.audio});
}

abstract class BiliEntry {
  late final String title;
  late final String pic;

  late final VideoSources sources; // DURL | Dash

  BiliEntry();

  bool isFetched = false;

  factory BiliEntry.fromHash(String hash) {
    final splitedHash = hash.split('-');
    if (splitedHash[0] != 'bili') {
      throw const FormatException('Bilibili hash should start with "bili-".');
    }

    switch (splitedHash[1]) {
      case 'video':
        return BiliVideo(bvid: splitedHash[2], p: int.parse(splitedHash[3]));
      case 'bungumi':
        return BiliBungumi(epid: int.parse(splitedHash[2]));
      default:
        throw FormatException('Unknown bilibili type: ${splitedHash[1]}');
    }
  }
  String get hash {
    if (this is BiliVideo) {
      final biliVideo = this as BiliVideo;
      return 'bili-video-${biliVideo.bvid}-${biliVideo.p}';
    }
    if (this is BiliBungumi) {
      final biliBungumi = this as BiliBungumi;
      return 'bili-bungumi-${biliBungumi.epid}';
    }
    return 'bilibili';
  }
}

class BiliVideo extends BiliEntry {
  final String bvid;
  final int p;

  late final String cid;
  late final int totalP;
  late final bool isHD;

  BiliVideo({required this.bvid, this.p = 1});
}

class BiliBungumi extends BiliEntry {
  final int epid;

  BiliBungumi({required this.epid});
}

class Bilibili {
  final getSess = getService<Bunga>().getBiliSess;

  Future<BiliEntry> getEntryFromUri(Uri uri) async {
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
            return BiliVideo(bvid: bvid, p: p);
          case 'bangumi':
            final epString = uri.pathSegments[2].substring(2);
            final epid = int.parse(epString);
            return BiliBungumi(epid: epid);
          default:
            throw 'Unknown url path: ${uri.path}';
        }

      default:
        throw 'Unknown host: ${uri.host}';
    }
  }

  Future<void> fetch(BiliEntry entry) async {
    if (entry.isFetched) return;
    switch (entry.runtimeType) {
      case const (BiliVideo):
        await _fetchVideo(entry as BiliVideo);
        break;
      case const (BiliBungumi):
        await _fetchBungumi(entry as BiliBungumi);
        break;
      default:
        logger.w('Unknown BiliEntry type: ${entry.runtimeType}');
    }
  }

  Future<void> _fetchVideo(BiliVideo video) async {
    logger.i('Bili video: start fetch BV=${video.bvid}, p=${video.p}');

    String? sess;
    await Future.wait([
      () async {
        // fetch cookie
        sess = await getSess();
        video.isHD = sess != null;
        if (!video.isHD) {
          logger.w('Bilibili: Cookie of serverless funtion outdated');
        }
      }(),
      () async {
        // fetch video info
        final response = await http.get(Uri.parse(
            'https://api.bilibili.com/x/web-interface/view?bvid=${video.bvid}'));
        final responseData = jsonDecode(response.body);
        if (responseData['code'] != 0) {
          throw 'Cannot get video info';
        }

        video.pic = responseData['data']['pic'];

        final List pages = responseData['data']['pages'];
        video.totalP = pages.length;
        video.title = video.totalP > 1
            ? '${responseData['data']['title']} [${video.p}/${video.totalP}]'
            : responseData['data']['title'];
        video.cid = pages[video.p - 1]['cid'].toString();
      }(),
    ]);

    // fetch video url with cookie and video info
    final response = await http.get(
      Uri.parse(
          'https://api.bilibili.com/x/player/playurl?bvid=${video.bvid}&cid=${video.cid}&qn=112'),
      headers: sess == null ? null : {"Cookie": 'SESSDATA=$sess'},
    );
    final responseData = jsonDecode(response.body);
    if (responseData['code'] == 0) {
      final durl = responseData['data']['durl'][0];
      video.sources = VideoSources(video: [
        durl['url'],
        ...durl['backup_url'] ?? [],
      ]);
    } else {
      // can't get url from api.bilibili.com
      logger.w('Cannot fetch by api');
      final response = await http.get(
        Uri.parse(
            'https://www.bilibili.com/video/BV${video.bvid}/?p=${video.p}'),
        headers: sess == null ? null : {'Cookie': 'SESSDATA=$sess'},
      );

      final regex =
          RegExp(r'<script>window.__playinfo__=(?<json>\{.*?\})</script>');
      final match = regex.firstMatch(response.body);
      if (match == null) throw 'Cannot fetch video';

      final playinfo = jsonDecode(match.namedGroup('json')!);
      final videoinfo = playinfo['data']['dash']['video'] as List;
      final autioinfo = playinfo['data']['dash']['audio'] as List;
      video.sources = VideoSources(
        video: videoinfo.map((e) => e['baseUrl'] as String).toList(),
        audio: autioinfo.map((e) => e['baseUrl'] as String).toList(),
      );
    }

    video.isFetched = true;
  }

  Future<void> _fetchBungumi(BiliBungumi bungumi) async {
    logger.i('Bili bungumi: start fetch epid=${bungumi.epid}');

    late final String? sess;
    await Future.wait([
      () async {
        // fetch cookie
        sess = await getSess();
      }(),
      () async {
        // fetch video info
        final response = await http.get(Uri.parse(
            'https://api.bilibili.com/pgc/view/web/season?ep_id=${bungumi.epid}'));
        final responseData =
            jsonDecode(utf8.decoder.convert(response.bodyBytes));
        if (responseData['code'] != 0) {
          throw 'Cannot get video info';
        }

        final episodes = responseData['result']['episodes'] as List;
        for (var episode in episodes) {
          if (episode['id'] == bungumi.epid) {
            bungumi.pic = episode['cover'];
            bungumi.title = episode['share_copy'];
            bungumi.isFetched = true;
            break;
          }
        }
        if (!bungumi.isFetched) {
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
          'https://api.bilibili.com/pgc/player/web/playurl?ep_id=${bungumi.epid}&qn=112'),
      headers: {
        'Cookie': 'SESSDATA=$sess',
        'Referer': 'https://www.bilibili.com',
      },
    );
    final responseData = jsonDecode(response.body);
    if (responseData['code'] != 0) throw 'Failed to fetch durls';

    final durl = responseData['result']['durl'][0];
    bungumi.sources = VideoSources(video: [
      durl['url'],
      ...durl['backup_url'] ?? [],
    ]);

    bungumi.isFetched = true;
  }
}
