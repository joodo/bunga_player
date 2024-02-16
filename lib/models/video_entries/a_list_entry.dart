part of 'video_entry.dart';

class AListEntry extends VideoEntry {
  static const hashPrefix = 'alist';

  AListEntry(String path) {
    this.path = path;
    hash = '$hashPrefix-${path.hashCode.toRadixString(36)}';
  }

  factory AListEntry.fromChannelData(ChannelData channelData) {
    final splits = channelData.videoHash.split('-');
    assert(splits.first == hashPrefix);
    assert(channelData.path != null);
    return AListEntry(channelData.path!);
  }

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch() async {
    if (_isFetched) return;

    logger.i('AList: start fetch video $path');
    final info = await getIt<AList>().get(path!);
    print(info);

    title = info.name;
    image = info.thumb;
    sources = VideoSources(video: [info.rawUrl!]);

    _isFetched = true;
  }
}
