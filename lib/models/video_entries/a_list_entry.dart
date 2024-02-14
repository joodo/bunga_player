part of 'video_entry.dart';

class AListEntry extends VideoEntry {
  static String hashFromPath(String path) => path.hashCode.toRadixString(36);
  static const hashPrefix = 'alist';

  AListEntry({String? path, String? pathHash})
      : _path = path,
        _pathHash = pathHash {
    assert(_path != null || _pathHash != null,
        'One of "hash" and "hashPath" should not be null.');
  }

  String? _path;
  String? get path => _path;

  String? _pathHash;
  @override
  String get hash {
    _pathHash ??= hashFromPath(_path!);
    return '$hashPrefix-${_pathHash!}';
  }

  factory AListEntry.fromChannelData(ChannelData channelData) {
    final splits = channelData.videoHash.split('-');
    assert(splits.first == hashPrefix);
    return AListEntry(pathHash: splits[1]);
  }

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch() async {
    if (_isFetched) return;

    _path ??= await getIt<Bunga>().getStringByHash(_pathHash!);
    logger.i('AList: start fetch video $_path');

    final info = await getIt<AList>().get(path!);
    title = info.name;
    image = info.thumb;
    sources = VideoSources(video: [info.rawUrl!]);

    _isFetched = true;
  }
}
