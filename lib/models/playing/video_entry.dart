class VideoSources {
  final List<String> video;
  final List<String>? audio;

  VideoSources({required this.video, this.audio});
}

abstract class VideoEntry {
  late final String title;
  late final String image;
  late final VideoSources sources; // DURL | Dash

  static final Map<String, VideoEntry Function(String hash)> fromHashMap = {};

  VideoEntry();

  bool get isFetched;
  Future<void> fetch();

  String get hash;
  factory VideoEntry.fromHash(String hash) {
    final prefix = hash.split('-').first;
    if (!fromHashMap.containsKey(prefix)) {
      throw FormatException('RemoteVideoEntry: unknown hash prefix: $prefix');
    }

    return fromHashMap[prefix]!(hash);
  }
}
