import 'package:bunga_player/models/playing/volume.dart';
import 'package:bunga_player/models/playing/watch_progress.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/player.dart';

class AudioTrack {
  final String id;
  final String? title;
  final String? language;

  AudioTrack(this.id, this.title, this.language);

  @override
  String toString() =>
      '[$id]${title != null ? ' $title' : ''}${language != null ? ' ($language)' : ''}';
}

class SubtitleTrack {
  final String id;
  final String? title;
  final String? language;
  final String? uri;

  SubtitleTrack({
    required this.id,
    this.title,
    this.language,
    this.uri,
  });

  bool get isExternal => uri != null;

  @override
  String toString() =>
      '[$id]${title != null ? ' $title' : ''}${language != null ? ' ($language)' : ''}';
}

abstract class Player {
  static const int maxVolume = 100;
  static const int minVolume = 0;
  Stream<Volume> get volumeStream;
  Future<void> setVolume(int volume);
  Future<void> setMute(bool isMute);

  Stream<Duration> get durationStream;
  Stream<Duration> get bufferStream;
  Stream<Duration> get positionStream;
  Stream<bool> get isBufferingStream;
  Future<void> seek(Duration position);

  Stream<PlayStatusType> get statusStream;
  Future<void> open(VideoEntry entry, [int sourceIndex = 0]);
  Future<void> pause();
  Future<void> play();
  Future<void> stop();
  Future<void> toggle();

  Stream<VideoEntry?> get videoEntryStream;
  Stream<int?> get sourceIndexStream;
  Map<String, WatchProgress> get watchProgresses;
  void clearAllWatchProgress();

  Future<void> setAudioTrackID(String id);
  Stream<Iterable<AudioTrack>> get audioTracksStream;
  Stream<String> get currentAudioTrackID;

  Future<void> setSubtitleTrackID(String id);
  Future<SubtitleTrack> loadSubtitleTrack(String uri);
  Stream<Iterable<SubtitleTrack>> get subtitleTracksStream;
  Stream<String> get currentSubtitleTrackID;

  Stream<int> get contrastStream;
  Future<void> setContrast(int volume);
  Future<void> resetContrast();

  Stream<double> get subDelayStream;
  Future<void> setSubDelay(double delay);
  Future<void> resetSubDelay();
  static const defaultSubSize = 50;
  Stream<int> get subSizeStream;
  Future<void> setSubSize(int size);
  Future<void> resetSubSize();
  Stream<int> get subPosStream;
  Future<void> setSubPos(int pos);
  Future<void> resetSubPos();
}
