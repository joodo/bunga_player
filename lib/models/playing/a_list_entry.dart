import 'package:bunga_player/models/playing/video_entry.dart';
import 'package:bunga_player/services/alist.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';

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

  factory AListEntry.fromHash(String hash) {
    final splits = hash.split('-');
    assert(splits.first == hashPrefix);
    return AListEntry(pathHash: splits[1]);
  }

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch() async {
    if (_isFetched) return;
    logger.i('AList: start fetch video $_path');

    _path ??= await getService<Bunga>().getStringByHash(_pathHash!);

    final info = await getService<AList>().get(path!);
    title = info.name;
    image = info.thumb;
    sources = VideoSources(video: [info.rawUrl!]);

    _isFetched = true;
  }
}
