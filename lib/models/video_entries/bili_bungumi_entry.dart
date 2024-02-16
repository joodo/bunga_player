part of 'video_entry.dart';

class BiliBungumiEntry extends VideoEntry {
  static const hashPrefix = 'bilibungumi';

  final int epid;

  BiliBungumiEntry({required this.epid}) {
    hash = '$hashPrefix-$epid';
    path = null;
  }

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch() async {
    if (_isFetched) return;

    logger.i('Bili bungumi: start fetch epid=$epid');

    final getSess = getIt<Bunga>().getBiliSess;
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
            image = episode['cover'];
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

  factory BiliBungumiEntry.fromChannelData(ChannelData channelData) {
    final splits = channelData.videoHash.split('-');
    assert(splits.first == hashPrefix);
    return BiliBungumiEntry(epid: int.parse(splits[1]));
  }
}
