import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/models/track.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:flutter/foundation.dart';

import '../models/video_entries/video_entry.dart';

enum PlayStatus {
  play,
  pause,
  stop;

  bool get isPlaying => this == play;
}

abstract class PlayService {
  static const int maxVolume = 100;
  static const int minVolume = 0;

  // TODO::
  Stream<Volume> get volumeStream;
  Future<void> setVolume(int volume);
  Future<void> setMute(bool isMute);

  Future<void> open(PlayPayload payload);

  ValueListenable<Duration> get durationNotifier;
  ValueListenable<Duration> get bufferNotifier;
  ValueListenable<bool> get isBufferingNotifier;
  ValueNotifier<Duration> get positionNotifier;
  void seek(Duration position);

  ValueNotifier<PlayStatus> get playStatusNotifier;
  void play();
  void pause();
  void toggle();
  void stop();

  // TODO: change to notifier
  Future<void> setRate(double rate);

  Future<Uint8List?> screenshot();

  Stream<VideoEntry?> get videoEntryStream;
  Stream<int?> get sourceIndexStream;

  ValueNotifier<Iterable<AudioTrack>> get audioTracksNotifier;
  ValueNotifier<AudioTrack> get audioTrackNotifier;

  ValueNotifier<Iterable<SubtitleTrack>> get subtitleTracksNotifier;
  ValueNotifier<SubtitleTrack> get subtitleTrackNotifier;
  Future<SubtitleTrack> loadSubtitleTrack(String uri);
  String? getExternalSubtitleUri(String trackId);

  // value -100~100
  ValueNotifier<int> get brightnessNotifier;
  ValueNotifier<int> get contrastNotifier;
  ValueNotifier<int> get saturationNotifier;
  ValueNotifier<int> get gammaNotifier;
  ValueNotifier<int> get hueNotifier;

  ValueNotifier<double> get subDelayNotifier;
  ValueNotifier<double> get subSizeNotifier;
  ValueNotifier<double> get subPosNotifier;
}
