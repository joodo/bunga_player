import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:styled_widget/styled_widget.dart';

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
        final buffer = Duration(milliseconds: playCachedBuffer);
        _buffer.value = _position.value + buffer;

        final almostFinished = _position.value.near(
          _duration.value,
          tolerance: _bufferThreshold,
        );
        if (_isBuffering.value) {
          if (buffer > _bufferThreshold || almostFinished) {
            _isBuffering.value = false;
          }
        } else {
          if (buffer <= const Duration(milliseconds: 100) && !almostFinished) {
            _isBuffering.value = true;
          }
        }
      },
      onPositionChanged: (positionMs, timestampMs) {
        _position.value = Duration(milliseconds: positionMs);
      },
      onPlayerSourceStateChanged: (state, reason) async {
        logger.i('Player state changed: $state, reason: $reason');
        switch (state) {
          case .playerStatePlaying:
            _playStatus.value = .play;
          case .playerStateOpenCompleted:
            _duration.value = Duration(
              milliseconds: await _player.getDuration(),
            );
            _playStatus.value = .pause;
            _openTask?.complete();
          case .playerStatePaused:
            _playStatus.value = .pause;
          case .playerStatePlaybackAllLoopsCompleted:
            _finishNotifier.fire();
            _playStatus.value = .pause;
          case .playerStateFailed:
            _playStatus.value = .stop;
            _openTask?.completeError(reason);
          default:
            _playStatus.value = .stop;
        }
      },
      onPlayerEvent: (eventCode, elapsedTime, message) {
        logger.i('Player event: $eventCode, message: $message');
        switch (eventCode) {
          /*case .playerEventBufferLow:
            _isBuffering.value = true;
          case .playerEventBufferRecover:
            _isBuffering.value = false;*/
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

  // Open
  _LocalVideoProxy? _videoProxy;
  Completer? _openTask;
  @override
  Future<void> open(PlayPayload payload, [Duration? start]) async {
    await _player.stop();
    await _videoProxy?.stop();
    if (_openTask?.isCompleted == false) {
      _openTask!.complete();
    }

    // Headers
    String url = payload.sources.videos[payload.videoSourceIndex];
    final headers = payload.sources.requestHeaders;
    if (headers != null) {
      _videoProxy = _LocalVideoProxy();
      url = await _videoProxy!.startProxy(url, headers);
    }

    // Open
    _openTask = Completer();
    await _player.open(url: url, startPos: start?.inMilliseconds ?? 0);
    await _openTask!.future;
  }

  // Duration
  final _duration = ValueNotifier(Duration.zero);
  @override
  ValueListenable<Duration> get durationNotifier => _duration;

  // Buffer
  static const _bufferThreshold = Duration(seconds: 2);
  final _buffer = ValueNotifier(Duration.zero);
  @override
  ValueListenable<Duration> get bufferNotifier => _buffer;

  final _isBuffering = ValueNotifier(true);
  @override
  ValueListenable<bool> get isBufferingNotifier => _isBuffering;

  // Position
  final _position = ValueNotifier(Duration.zero);
  @override
  ValueListenable<Duration> get positionNotifier => _position;
  @override
  Future<void> seek(Duration position) => _player.seek(position.inMilliseconds);

  // Playback
  final _playStatus = ValueNotifier<PlayStatus>(.stop);
  @override
  ValueListenable<PlayStatus> get playStatusNotifier => _playStatus;
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> stop() => _player.stop();
  final _finishNotifier = _SimpleEvent();
  @override
  Listenable get finishNotifier => _finishNotifier;

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
    return AgoraVideoView(controller: _player).backgroundColor(Colors.black);
  }
}

class _SimpleEvent extends ChangeNotifier {
  void fire() => notifyListeners();
}

class _LocalVideoProxy {
  HttpServer? _server;
  final HttpClient _httpClient = HttpClient();

  Future<String> startProxy(
    String remoteUrl,
    Map<String, String> headers,
  ) async {
    await stop();
    _server = await HttpServer.bind('127.0.0.1', 0);

    _server!.listen((HttpRequest request) async {
      try {
        final clientReq = await _httpClient.getUrl(Uri.parse(remoteUrl));

        headers.forEach((key, value) => clientReq.headers.set(key, value));
        String? range = request.headers.value('range');
        if (range != null) clientReq.headers.set('range', range);

        final clientRes = await clientReq.close();

        request.response.statusCode = clientRes.statusCode;

        request.response.headers.set('Content-Type', 'video/mp4');
        request.response.headers.set('Accept-Ranges', 'bytes');
        request.response.headers.set('Server', 'Tengine');

        clientRes.headers.forEach((name, values) {
          String n = name.toLowerCase();
          if (n == 'content-range' ||
              n == 'content-length' ||
              n == 'last-modified') {
            request.response.headers.set(name, values.join(','));
          }
          if (n == 'etag') {
            String etag = values.join(',');
            request.response.headers.set(
              'etag',
              etag.startsWith('"') ? etag : '"$etag"',
            );
          }
        });

        await request.response.addStream(clientRes);
        await request.response.close();
      } catch (e) {
        request.response.close();
      }
    });

    return "http://127.0.0.1:${_server!.port}/video.mp4";
  }

  Future<void> stop() async => await _server?.close(force: true);
}
