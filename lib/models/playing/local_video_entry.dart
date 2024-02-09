import 'dart:io';

import 'package:bunga_player/models/playing/video_entry.dart';
import 'package:crclib/catalog.dart';
import 'package:file_selector/file_selector.dart';

class LocalVideoEntry extends VideoEntry {
  LocalVideoEntry.fromFile(XFile file) {
    sources = VideoSources(video: [file.path]);
    title = file.name;
    image = '';
  }

  late final String _hash;
  @override
  String get hash => _hash;

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch() async {
    final crcValue = await File(sources.video.first)
        .openRead()
        .take(1000)
        .transform(Crc32Xz())
        .single;
    _hash = 'local-${crcValue.toString()}';

    _isFetched = true;
  }
}
