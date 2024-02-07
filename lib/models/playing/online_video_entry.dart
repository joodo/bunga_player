class VideoSources {
  final List<String> video;
  final List<String>? audio;

  VideoSources({required this.video, this.audio});
}

abstract class OnlineVideoEntry {
  late final String title;
  late final String pic;

  late final VideoSources sources; // DURL | Dash

  static final Map<String, OnlineVideoEntry Function(String hash)> fromHashMap =
      {};

  OnlineVideoEntry();

  bool get isFetched;
  Future<void> fetch();

  factory OnlineVideoEntry.fromHash(String hash) {
    final prefix = hash.split('-').first;
    if (!fromHashMap.containsKey(prefix)) {
      throw FormatException('RemoteVideoEntry: unknown hash prefix: $prefix');
    }

    return fromHashMap[prefix]!(hash);
  }
  String get hash;
}
