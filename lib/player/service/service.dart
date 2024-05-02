import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/watch_progress.dart';
import '../models/video_entries/video_entry.dart';

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

class WatchProgresses {
  final WatchProgress? Function(String videoEntryId) get;
  final int Function() _count;
  final VoidCallback clearAll;

  WatchProgresses({
    required this.get,
    required int Function() count,
    required this.clearAll,
  }) : _count = count;

  int get count => _count();
}

abstract class Player {
  static const int maxVolume = 100;
  static const int minVolume = 0;

  Widget get videoWidget;

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
  Future<void> setRate(double rate);

  Future<Uint8List?> screenshot();

  Stream<VideoEntry?> get videoEntryStream;
  Stream<int?> get sourceIndexStream;
  WatchProgresses get watchProgresses;

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
