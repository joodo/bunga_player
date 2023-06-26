import 'dart:convert';

import 'package:bunga_player/singletons/logger.dart';
import 'package:bunga_player/constants/secrets.dart';
import 'package:http/http.dart' as http;

class BiliVideo {
  final String bvid;
  final int p;

  late final String title;
  late final String aid;
  late final String cid;
  late final String pic;
  late final int totalP;

  late final List<String> videoUrls;
  late final bool isHD;

  BiliVideo({
    required this.bvid,
    this.p = 1,
  });

  factory BiliVideo.fromHash(String hash) {
    final splitedHash = hash.split('-');
    if (splitedHash[0] != 'bili') {
      throw const FormatException('Bilibili hash should start with "bili-".');
    }

    return BiliVideo(
      bvid: splitedHash[1],
      p: int.parse(splitedHash[2]),
    );
  }

  bool _isFetched = false;
  bool get isFetched => _isFetched;
  Future<void> fetch() async {
    if (_isFetched) return;
    logger.i('Bili video: start fetch BV=$bvid, p=$p');

    late final String? sess;
    await Future.wait([
      () async {
        // fetch cookie
        final response = await http.get(Uri.parse(
            'https://www.joodo.club/api/bilibili-sessdata?key=${BungaKey.key}'));
        if (response.statusCode == 200) {
          sess = response.body;
          isHD = true;
        } else {
          sess = null;
          isHD = false;
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

        aid = responseData['data']['aid'].toString();
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
          'https://api.bilibili.com/x/player/playurl?avid=$aid&cid=$cid&qn=112'),
      headers: sess == null ? null : {"Cookie": 'SESSDATA=$sess'},
    );
    logger.i('Bili video playurl: ${response.body}');
    final responseData = jsonDecode(response.body);
    if (responseData['code'] != 0) {
      throw 'Cannot get video url';
    }

    final durl = responseData['data']['durl'][0];
    videoUrls = [
      durl['url'],
      ...durl['backup_url'] ?? [],
    ];

    _isFetched = true;
    logger.i('Bili video: finish fetch.');
  }

  static Future<BiliVideo> fromUrl(Uri url) async {
    switch (url.host) {
      case 'b23.tv':
        final req = http.Request("Get", url)..followRedirects = false;
        final baseClient = http.Client();
        final response = await baseClient.send(req);
        final redirectUri = Uri.parse(response.headers['location']!);
        logger.i('Bili video: redirect to $redirectUri');
        return fromUrl(redirectUri);
      case 'www.bilibili.com':
        final regex = RegExp(r'\/BV(?<bvid>[A-Za-z0-9]*)\/?');

        final match = regex.firstMatch(url.path);
        if (match == null) throw 'No bv found in url';
        final bvid = match.namedGroup('bvid')!;

        final p = int.parse(url.queryParameters['p'] ?? '1');
        return BiliVideo(bvid: bvid, p: p);
      default:
        throw 'Unknown host: ${url.host}';
    }
  }
}
