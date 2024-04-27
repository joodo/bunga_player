part of 'video_entry.dart';

class AListEntry extends VideoEntry {
  static const hashPrefix = 'alist';
  static bool useThumbProxy = true;

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
  Future<void> fetch(BuildContext context) async {
    if (_isFetched) return;

    final client = context.read<AListClient?>();
    assert(client != null);

    logger.i('AList: start fetch video $path');
    final info = await client!.get(path!);

    title = info.name;
    image = AListEntry.useThumbProxy ? 'alist://$path' : info.thumb;
    sources = VideoSources(videos: [info.rawUrl!]);

    _isFetched = true;
  }
}
