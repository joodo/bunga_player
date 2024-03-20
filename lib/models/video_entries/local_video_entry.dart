part of 'video_entry.dart';

class LocalVideoEntry extends VideoEntry {
  LocalVideoEntry.fromFile(XFile file) {
    sources = VideoSources(videos: [file.path]);
    title = file.name;
    image = null;
    path = null;
  }

  bool _isFetched = false;
  @override
  bool get isFetched => _isFetched;
  @override
  Future<void> fetch(BuildContext context) async {
    final crcValue = await File(sources.videos.first)
        .openRead()
        .take(1000)
        .transform(Crc32Xz())
        .single;
    hash = 'local-${crcValue.toString()}';

    _isFetched = true;
  }
}
