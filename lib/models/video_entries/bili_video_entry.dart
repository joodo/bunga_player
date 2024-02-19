part of 'video_entry.dart';

class BiliVideoEntry extends VideoEntry {
  static const hashPrefix = 'bilivideo';

  final String bvid;
  final int p;

  late final String cid;
  late final int totalP;
  late final bool isHD;

  BiliVideoEntry({required this.bvid, this.p = 1}) {
    hash = '$hashPrefix-$bvid-$p';
    path = null;
  }

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch() async {
    if (_isFetched) return;

    logger.i('Bili video: start fetch BV=$bvid, p=$p');

    final getSess = getIt<Bunga>().getBiliSess;
    String? sess;
    await Future.wait([
      () async {
        // fetch cookie
        sess = await getSess();
        isHD = sess != null;
        if (!isHD) {
          getIt<Toast>().show('无法获取高清视频');
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

        image = responseData['data']['pic'];

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
      sources = VideoSources(videos: [
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
        videos: videoinfo.map((e) => e['baseUrl'] as String).toList(),
        audios: autioinfo.map((e) => e['baseUrl'] as String).toList(),
      );
    }

    _isFetched = true;
  }

  factory BiliVideoEntry.fromChannelData(ChannelData channelData) {
    final splits = channelData.videoHash.split('-');
    assert(splits.first == hashPrefix);
    return BiliVideoEntry(bvid: splits[1], p: int.parse(splits[2]));
  }
}
