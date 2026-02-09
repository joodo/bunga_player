import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/services/logger.dart';

import 'service.dart';
import '../models/play_payload.dart';
import '../models/track.dart';

class AgoraPlayService extends PlayService {
  RtcEngine? _engine;

  MediaPlayerController? __player;
  MediaPlayerController get _player => __player!;

  Future<void> registerEngine(RtcEngine engine) async {
    _engine = engine;

    __player = MediaPlayerController(
      rtcEngine: _engine!,
      canvas: VideoCanvas(uid: 0, renderMode: .renderModeHidden),
      useFlutterTexture: true,
    );
    await _player.initialize();

    _player.registerPlayerSourceObserver(_createObserver());

    playbackRateNotifier.addListener(() {
      _player.setPlaybackSpeed((100.0 * playbackRateNotifier.value).toInt());
    });
    _volume.addListener(() {
      _player.adjustPlayoutVolume(_volume.value.volume);
      _player.mute(_volume.value.mute);
    });
  }

  void unregisterEngine() {
    __player = null;
  }

  MediaPlayerSourceObserver _createObserver() {
    return MediaPlayerSourceObserver(
      onPlayBufferUpdated: (playCachedBuffer) {
        _buffer.value =
            _position.value + Duration(milliseconds: playCachedBuffer);
      },
      onPositionChanged: (positionMs, timestampMs) {
        _position.value = Duration(milliseconds: positionMs);
      },
      onPlayerSourceStateChanged: (state, reason) {
        logger.i('Player state changed: $state, reason: $reason');
        switch (state) {
          case .playerStatePlaying:
            _playStatus.value = .play;
          case .playerStateOpenCompleted:
          case .playerStatePaused:
            _playStatus.value = .pause;
          default:
            _playStatus.value = .stop;
        }
      },
      onPlayerEvent: (eventCode, elapsedTime, message) {
        logger.i('Player event: $eventCode, message: $message');
        switch (eventCode) {
          case .playerEventBufferLow:
            _isBuffering.value = true;
          case .playerEventBufferRecover:
            _isBuffering.value = false;
          default:
            {}
        }
      },
    );
  }

  // Volume
  final _volume = ValueNotifier(Volume(volume: Volume.max));
  @override
  ValueNotifier<Volume> get volumeNotifier => _volume;

  @override
  Future<void> open(PlayPayload payload, [Duration? start]) async {
    await _player.stop();

    // Headers
    final headers = payload.sources.requestHeaders;
    final headerString = headers?.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\r\n');
    print('Header string: $headerString');
    if (headerString != null) {
      await _player.setPlayerOptionInString(
        key: 'http-header-fields',
        value: headerString,
      );
    }

    // Open
    final url = payload.sources.videos[payload.videoSourceIndex];
    await _player.open(url: url, startPos: start?.inMilliseconds ?? 0);
    await Future.delayed(const Duration(seconds: 1));

    // Update info
    _duration.value = Duration(milliseconds: await _player.getDuration());
  }

  // Duration
  final _duration = ValueNotifier(Duration.zero);
  @override
  ValueListenable<Duration> get durationNotifier => _duration;

  // Buffer
  final _buffer = ValueNotifier(Duration.zero);
  @override
  ValueListenable<Duration> get bufferNotifier => _buffer;

  final _isBuffering = ValueNotifier(false);
  @override
  ValueListenable<bool> get isBufferingNotifier => _isBuffering;

  // Position
  final _position = ValueNotifier(Duration.zero);
  @override
  ValueListenable<Duration> get positionNotifier => _position;
  @override
  void seek(Duration position) {
    _player.seek(position.inMilliseconds);
  }

  // Playback
  final _playStatus = ValueNotifier<PlayStatus>(.stop);
  @override
  ValueListenable<PlayStatus> get playStatusNotifier => _playStatus;
  @override
  void pause() => _player.pause();
  @override
  void play() => _player.play();
  @override
  void stop() => _player.stop();

  // Playback rate
  @override
  final playbackRateNotifier = ValueNotifier(1.0);

  // Audio Track
  @override
  // TODO: implement audioTrackNotifier
  ValueNotifier<AudioTrack> get audioTrackNotifier =>
      throw UnimplementedError();
  @override
  // TODO: implement audioTracksNotifier
  ValueNotifier<Iterable<AudioTrack>> get audioTracksNotifier =>
      throw UnimplementedError();

  // Subtitle Track
  @override
  Future<SubtitleTrack> loadSubtitleTrack(String uri) {
    // TODO: implement loadSubtitleTrack
    throw UnimplementedError();
  }

  @override
  SubtitleTrack setSubtitleTrack(String id) {
    // TODO: implement setSubtitleTrack
    throw UnimplementedError();
  }

  @override
  // TODO: implement subtitleTrackNotifier
  ValueNotifier<SubtitleTrack> get subtitleTrackNotifier =>
      throw UnimplementedError();

  @override
  // TODO: implement subtitleTracksNotifier
  ValueNotifier<Iterable<SubtitleTrack>> get subtitleTracksNotifier =>
      throw UnimplementedError();

  @override
  // TODO: implement subDelayNotifier
  ValueNotifier<double> get subDelayNotifier => throw UnimplementedError();

  @override
  // TODO: implement subPosNotifier
  ValueNotifier<double> get subPosNotifier => throw UnimplementedError();

  @override
  // TODO: implement subSizeNotifier
  ValueNotifier<double> get subSizeNotifier => throw UnimplementedError();

  // Utils

  @override
  // TODO: implement proxyNotifier
  ValueNotifier<String?> get proxyNotifier => throw UnimplementedError();

  @override
  Future<Uint8List?> screenshot() {
    // TODO: implement screenshot
    throw UnimplementedError();
  }

  // Video effects are not supported by agora
  // So we just throw unimplemented error for all of them
  @override
  ValueNotifier<int> get brightnessNotifier => throw UnimplementedError();
  @override
  ValueNotifier<int> get contrastNotifier => throw UnimplementedError();
  @override
  ValueNotifier<int> get gammaNotifier => throw UnimplementedError();
  @override
  ValueNotifier<int> get hueNotifier => throw UnimplementedError();
  @override
  ValueNotifier<int> get saturationNotifier => throw UnimplementedError();

  @override
  Widget buildVideoWidget() {
    //return const SizedBox.shrink();
    return AgoraVideoView(controller: _player);
  }
}
