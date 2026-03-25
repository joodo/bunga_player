import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/models/volume.dart';

import '../models/play_payload.dart';
import '../models/track.dart';

enum PlayStatus {
  play,
  pause,
  stop;

  bool get isPlaying => this == play;
}

abstract class MediaPlayer {
  static MediaPlayer get i => getIt<MediaPlayer>();

  ValueNotifier<Volume> get volumeNotifier;

  Future<void> open(PlayPayload payload, [Duration? start]);

  ValueListenable<Duration> get durationNotifier;
  Duration get duration => durationNotifier.value;
  ValueListenable<Duration> get bufferNotifier;
  Duration get buffer => bufferNotifier.value;
  ValueListenable<bool> get isBufferingNotifier;
  bool get isBuffering => isBufferingNotifier.value;
  ValueListenable<Duration> get positionNotifier;
  Duration get position => positionNotifier.value;
  ValueNotifier<double> get rateNotifier;
  double get rate => rateNotifier.value;
  Future<void> seek(Duration position);

  ValueListenable<PlayStatus> get playStatusNotifier;
  bool get isPlaying => playStatusNotifier.value.isPlaying;
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> toggle() =>
      playStatusNotifier.value.isPlaying ? pause() : play();
  Listenable get finishNotifier;

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

  Future<void> dispose();
}
