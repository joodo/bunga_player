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
  ValueListenable<Duration> get bufferNotifier;
  ValueListenable<bool> get isBufferingNotifier;
  ValueListenable<Duration> get positionNotifier;
  ValueNotifier<double> get rateNotifier;
  Future<void> seek(Duration position);

  ValueListenable<PlayStatus> get playStatusNotifier;
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

  void dispose() {}
}
