part of 'video_entry.dart';

class M3u8Entry extends VideoEntry {
  static const hashPrefix = 'm3u8';

  M3u8Entry(String url) {
    path = url;
    hash = '$hashPrefix-${path.hashCode.toRadixString(36)}';
  }

  factory M3u8Entry.fromChannelData(ChannelData channelData) {
    final splits = channelData.videoHash.split('-');
    assert(splits.first == hashPrefix);
    return M3u8Entry(channelData.path!);
  }

  bool _isFetched = false;
  @override
  Future<void> fetch(Locator read) async {
    if (_isFetched) return;

    final response = await read<BungaClient>().parseVideoUrl(path!);
    image = response['image'];
    title = response['title'];

    final list = response['videos'] as List;
    sources = VideoSources(videos: list.map((e) => e as String).toList());
    _isFetched = true;
  }

  @override
  bool get isFetched => _isFetched;
}
