import 'dart:ui';

import 'package:bunga_player/utils/models/volume.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/play_payload.dart';
import '../models/track.dart';

enum PlayStatus {
  play,
  pause,
  stop;

  bool get isPlaying => this == play;
}

abstract class PlayService {
  static const int maxVolume = 100;
  static const int minVolume = 0;

  ValueNotifier<Volume> get volumeNotifier;

  Future<void> open(PlayPayload payload, [Duration? start]);

  ValueListenable<Duration> get durationNotifier;
  ValueListenable<Duration> get bufferNotifier;
  ValueListenable<bool> get isBufferingNotifier;
  ValueListenable<Duration> get positionNotifier;
  ValueNotifier<double> get playbackRateNotifier;
  void seek(Duration position);

  ValueListenable<PlayStatus> get playStatusNotifier;
  void play();
  void pause();
  void stop();
  void toggle() => playStatusNotifier.value.isPlaying ? pause() : play();

  Future<Uint8List?> screenshot();

  ValueNotifier<Iterable<AudioTrack>> get audioTracksNotifier;
  ValueNotifier<AudioTrack> get audioTrackNotifier;

  ValueNotifier<Iterable<SubtitleTrack>> get subtitleTracksNotifier;
  ValueNotifier<SubtitleTrack> get subtitleTrackNotifier;
  SubtitleTrack setSubtitleTrack(String id);
  Future<SubtitleTrack> loadSubtitleTrack(String uri);

  // value -100~100
  ValueNotifier<int> get brightnessNotifier;
  ValueNotifier<int> get contrastNotifier;
  ValueNotifier<int> get saturationNotifier;
  ValueNotifier<int> get gammaNotifier;
  ValueNotifier<int> get hueNotifier;

  ValueNotifier<double> get subDelayNotifier;
  ValueNotifier<double> get subSizeNotifier;
  ValueNotifier<double> get subPosNotifier;

  ValueNotifier<String?> get proxyNotifier;

  ValueListenable<Size?> get videoSizeNotifier;

  Widget buildVideoWidget();
}
