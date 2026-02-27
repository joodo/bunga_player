import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart' as agora;
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';

import 'service.dart';
import '../models/play_payload.dart';
import '../models/track.dart';

class AgoraMediaPlayer extends MediaPlayer {
  static agora.RtcEngine? engine;

  AgoraMediaPlayer() {
    if (engine != null) registerEngine();
  }

  agora.MediaPlayerController? __player;
  agora.MediaPlayerController get _player => __player!;

  Future<void> registerEngine() async {
    __player = agora.MediaPlayerController(
      rtcEngine: AgoraMediaPlayer.engine!,
      canvas: agora.VideoCanvas(uid: 0, renderMode: .renderModeHidden),
      useFlutterTexture: true,
    );
    await _player.initialize();

    _player.registerPlayerSourceObserver(_createObserver());

    playbackRateNotifier.addListener(_onPlaybackRateChanged);
    _volume.addListener(() {
      _player.adjustPlayoutVolume(_volume.value.level.toLevel);
      _player.mute(_volume.value.mute);
    });
  }

  Future<void> unregisterEngine() async {
    await _disposePlayer();
    engine = null;
  }

  Future<void> _disposePlayer() async {
    playbackRateNotifier.removeListener(_onPlaybackRateChanged);

    if (__player != null) {
      await _player.stop();
      await _player.dispose();
      __player = null;
    }
  }

  agora.MediaPlayerSourceObserver _createObserver() {
    return agora.MediaPlayerSourceObserver(
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
        //logger.i('Player state changed: $state, reason: $reason');
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
            _playStatus.value = .pause;
            _finishNotifier.fire();
          case .playerStateFailed:
            _playStatus.value = .stop;
            _openTask?.completeError(reason);
          default:
            _playStatus.value = .stop;
        }
      },
      onPlayerEvent: (eventCode, elapsedTime, message) {
        //logger.i('Player event: $eventCode, message: $message');
        switch (eventCode) {
          /*case .playerEventBufferLow:
            _isBuffering.value = true;
          case .playerEventBufferRecover:
            _isBuffering.value = false;*/
          default:
            {}
        }
      },
      onPlayerInfoUpdated: (info) {
        Size? size;
        try {
          size = Size(
            info.videoWidth!.toDouble(),
            info.videoHeight!.toDouble(),
          );
          if (size.isEmpty) size = null;
        } on TypeError catch (_) {
          size = null;
        }
        _videoSizeNotifier.value = size;
      },
    );
  }

  void _onPlaybackRateChanged() {
    _player.setPlaybackSpeed((100.0 * playbackRateNotifier.value).toInt());
  }

  @override
  Future<void> dispose() async {
    if (_openTask?.isCompleted == false) {
      _openTask?.completeError('Service disposed');
    }

    await _disposePlayer();

    playbackRateNotifier.dispose();
    _volume.dispose();
    _duration.dispose();
    _buffer.dispose();
    _isBuffering.dispose();
    _position.dispose();
    _playStatus.dispose();

    await _videoProxy.stop();

    super.dispose();
  }

  // Volume
  final _volume = ValueNotifier(Volume.max);
  @override
  ValueNotifier<Volume> get volumeNotifier => _volume;

  // Open
  final _videoProxy = _LocalVideoProxy();
  Completer? _openTask;
  @override
  Future<void> open(PlayPayload payload, [Duration? start]) async {
    await _player.stop();
    if (_openTask?.isCompleted == false) {
      _openTask!.complete();
    }

    // Headers
    String url = payload.sources.videos[payload.videoSourceIndex].url;
    final headers = payload.sources.requestHeaders;
    if (headers != null || proxyNotifier.value != null) {
      url = await _videoProxy.startProxy(url, headers, proxyNotifier.value);
    }

    // Open
    _openTask = Completer();
    await _player.open(url: url, startPos: start?.inMilliseconds ?? 0);
    await _openTask!.future;
  }

  // Video size
  final _videoSizeNotifier = ValueNotifier<Size?>(null);
  @override
  ValueListenable<Size?> get videoSizeNotifier => _videoSizeNotifier;

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
  Future<void> seek(Duration position) async {
    await _player.seek(position.inMilliseconds);
    await _position.waitUntil((value) => position == value);
  }

  // Playback
  final _playStatus = ValueNotifier<PlayStatus>(.stop);
  @override
  ValueListenable<PlayStatus> get playStatusNotifier => _playStatus;
  @override
  Future<void> pause() {
    _player.pause();
    return _playStatus.waitUntil((status) => !status.isPlaying);
  }

  @override
  Future<void> play() {
    _player.play();
    return _playStatus.waitUntil((status) => status.isPlaying);
  }

  @override
  Future<void> stop() => _player.stop();
  final _finishNotifier = _SimpleEvent();
  @override
  Listenable get finishNotifier => _finishNotifier;

  // Playback rate
  @override
  final playbackRateNotifier = ValueNotifier(1.0);

  // Utils

  @override
  late final proxyNotifier = ValueNotifier<String?>(null);

  @override
  Future<Uint8List?> screenshot() async {
    final boundary =
        _widgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  // These are not supported by agora
  // So we just throw unimplemented error for all of them
  // Video
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
  // Audio
  @override
  ValueNotifier<AudioTrack> get audioTrackNotifier =>
      throw UnimplementedError();
  @override
  ValueNotifier<Iterable<AudioTrack>> get audioTracksNotifier =>
      throw UnimplementedError();
  // Subtitle
  @override
  Future<SubtitleTrack> loadSubtitleTrack(String uri) =>
      throw UnimplementedError();
  @override
  SubtitleTrack setSubtitleTrack(String id) => throw UnimplementedError();
  @override
  ValueNotifier<SubtitleTrack> get subtitleTrackNotifier =>
      throw UnimplementedError();
  @override
  ValueNotifier<Iterable<SubtitleTrack>> get subtitleTracksNotifier =>
      throw UnimplementedError();
  @override
  ValueNotifier<double> get subDelayNotifier => throw UnimplementedError();
  @override
  ValueNotifier<double> get subPosNotifier => throw UnimplementedError();
  @override
  ValueNotifier<double> get subSizeNotifier => throw UnimplementedError();

  final _widgetKey = GlobalKey();
  @override
  Widget buildVideoWidget() {
    return RepaintBoundary(
      key: _widgetKey,
      child: agora.AgoraVideoView(
        controller: _player,
      ).backgroundColor(Colors.black),
    );
  }
}

class _SimpleEvent extends ChangeNotifier {
  void fire() => notifyListeners();
}

class _LocalVideoProxy {
  HttpServer? _server;
  final _httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) =>
        true;

  // To handle relative paths in m3u8, we store the base remote URL
  String? _baseRemoteUrl;

  Future<String> startProxy(
    String remoteUrl,
    Map<String, String>? headers,
    String? proxy,
  ) async {
    _setProxy(proxy);

    await stop();
    _server = await HttpServer.bind('127.0.0.1', 0);

    // Parse the base URL (e.g., http://site.com/path/to/video.m3u8 -> http://site.com/path/to/)
    final uri = Uri.parse(remoteUrl);
    _baseRemoteUrl = uri.resolve('.').toString();

    _server!.listen((HttpRequest request) async {
      try {
        Uri targetUri;
        if (request.uri.path == '/proxy_video') {
          targetUri = Uri.parse(remoteUrl);
        } else {
          // Resolve relative paths (for .ts files or sub-m3u8)
          targetUri = Uri.parse(
            _baseRemoteUrl!,
          ).resolve(request.uri.path.substring(1));
        }
        final clientReq = await _httpClient.getUrl(targetUri);

        // Forward headers from agora
        headers?.forEach((key, value) => clientReq.headers.set(key, value));

        // Handle Range requests for MP4 seeking
        String? range = request.headers.value('range');
        if (range != null) clientReq.headers.set('range', range);

        final clientRes = await clientReq.close();

        request.response.statusCode = clientRes.statusCode;

        // Headers
        clientRes.headers.forEach((name, values) {
          final String n = name.toLowerCase();

          if (n == 'transfer-encoding' ||
              n == 'content-encoding' ||
              n == 'connection' ||
              n == 'content-disposition') {
            return;
          }

          if (n == 'etag') {
            String etag = values.join(',');
            request.response.headers.set(
              'etag',
              etag.startsWith('"') ? etag : '"$etag"',
            );
          } else {
            request.response.headers.set(name, values.join(','));
          }
        });

        request.response.headers.set('Accept-Ranges', 'bytes');
        request.response.headers.set('Access-Control-Allow-Origin', '*');
        request.response.headers.set('Access-Control-Allow-Headers', '*');
        request.response.headers.set('Server', 'BungaPlayerProxy/1.0');

        await request.response.addStream(clientRes);
        await request.response.close();
      } catch (e) {
        request.response.close();
      }
    });

    return "http://127.0.0.1:${_server!.port}/proxy_video";
  }

  Future<void> stop() async => await _server?.close(force: true);

  void _setProxy(String? proxy) {
    if (proxy != null) {
      _httpClient.findProxy = (uri) {
        return "PROXY $proxy";
      };
    } else {
      _httpClient.findProxy = (uri) {
        return "DIRECT";
      };
    }
  }
}
