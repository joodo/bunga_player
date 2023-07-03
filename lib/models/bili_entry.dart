import 'dart:convert';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/constants/secrets.dart';
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
  late final bool isHD;

  BiliEntry();

  bool _isFetched = false;
  bool get isFetched => _isFetched;
  Future<void> fetch();

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

  static Future<BiliEntry> fromUrl(Uri url) async {
    switch (url.host) {
      case 'b23.tv':
        final req = http.Request("Get", url)..followRedirects = false;
        final baseClient = http.Client();
        final response = await baseClient.send(req);
        final redirectUri = Uri.parse(response.headers['location']!);
        logger.i('Bili video: redirect to $redirectUri');
        return fromUrl(redirectUri);
      case 'www.bilibili.com':
        switch (url.pathSegments[0]) {
          case 'video':
            final regex = RegExp(r'\/BV(?<bvid>[A-Za-z0-9]*)\/?');

            final match = regex.firstMatch(url.path);
            if (match == null) throw 'No bv found in url';
            final bvid = match.namedGroup('bvid')!;

            final p = int.parse(url.queryParameters['p'] ?? '1');
            return BiliVideo(bvid: bvid, p: p);
          case 'bangumi':
            final epString = url.pathSegments[2].substring(2);
            final epid = int.parse(epString);
            return BiliBungumi(epid: epid);
          default:
            throw 'Unknown url path: ${url.path}';
        }

      default:
        throw 'Unknown host: ${url.host}';
    }
  }

  Future<String?> _getSess() async {
    final response = await http.get(Uri.parse(
        'https://www.joodo.club/api/bilibili-sessdata?key=${BungaKey.key}'));
    if (response.statusCode == 200) {
      isHD = true;
      return response.body;
    } else {
      isHD = false;
      return null;
    }
  }
}

class BiliVideo extends BiliEntry {
  final String bvid;
  final int p;

  late final String cid;
  late final int totalP;

  BiliVideo({required this.bvid, this.p = 1});

  @override
  Future<void> fetch() async {
    if (_isFetched) return;
    logger.i('Bili video: start fetch BV=$bvid, p=$p');

    late final String? sess;
    await Future.wait([
      () async {
        // fetch cookie
        sess = await _getSess();
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
}

class BiliBungumi extends BiliEntry {
  final int epid;

  BiliBungumi({required this.epid});

  @override
  Future<void> fetch() async {
    if (_isFetched) return;
    logger.i('Bili bungumi: start fetch epid=$epid');

    late final String? sess;
    await Future.wait([
      () async {
        // fetch cookie
        sess = await _getSess();
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
        for (var episode in episodes) {
          if (episode['id'] == epid) {
            pic = episode['cover'];
            title = episode['share_copy'];
            _isFetched = true;
            break;
          }
        }
        if (!_isFetched) {
          throw 'Cannot found episode info';
        }
      }(),
    ]);

    // fetch video url with cookie and epid
    final response = await http.get(
      Uri.parse(
          'https://api.bilibili.com/pgc/player/web/playurl?ep_id=$epid&qn=112'),
      headers: sess == null
          ? null
          : {
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
  }
}
