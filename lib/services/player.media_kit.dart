import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:bunga_player/models/playing/volume.dart';
import 'package:bunga_player/models/playing/watch_progress.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/player.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' as media_kit;
import 'package:media_kit_video/media_kit_video.dart' as media_kit;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

class MediaKitPlayer implements Player {
  MediaKitPlayer() {
    media_kit.MediaKit.ensureInitialized();

    // set mpv auto reconnect
    // from https://github.com/mpv-player/mpv/issues/5793#issuecomment-553877261
    _setProperty('stream-lavf-o-append', 'reconnect_on_http_error=4xx,5xx');
    _setProperty('stream-lavf-o-append', 'reconnect_delay_max=30');
    _setProperty('stream-lavf-o-append', 'reconnect_streamed=yes');

    // Things when video finish
    _player.stream.playing.listen(
      (isPlay) {
        if (_player.state.playlist.medias.isEmpty) return;

        final remain = _player.state.duration - _player.state.position;
        if (remain.inMilliseconds < 500) {
          pause().then((_) => seek(Duration.zero));
        }
      },
    );

    // When new sub loaded
    _player.stream.tracks.listen(
      (tracks) {
        if (_waitingNewSub) {
          setSubtitleTrackID(tracks.subtitle.last.id);
          _waitingNewSub = false;
        }
      },
    );

    _loadWatchProgress();

    _setUpLogs();
  }

  late final _player = media_kit.Player(
    configuration: const media_kit.PlayerConfiguration(
      logLevel: media_kit.MPVLogLevel.warn,
    ),
  );
  late final controller = media_kit.VideoController(_player);

  // Volume
  Volume _volume = Volume(volume: 100, mute: false);
  late final _volumeController = StreamController<Volume>.broadcast();
  @override
  Stream<Volume> get volumeStream => _volumeController.stream;
  @override
  Future<void> setMute(bool isMute) {
    _volume = Volume(volume: _volume.volume, mute: isMute);
    _volumeController.add(_volume);

    return isMute
        ? _player.setVolume(0)
        : _player.setVolume(_volume.volume.toDouble());
  }

  @override
  Future<void> setVolume(int volume) {
    _volume = Volume(volume: volume, mute: false);
    _volumeController.add(_volume);
    return _player.setVolume(volume.toDouble());
  }

  // Buffer, Duration, Position
  @override
  Stream<Duration> get bufferStream => _player.stream.buffer;
  @override
  Stream<Duration> get durationStream => _player.stream.duration;
  @override
  Stream<Duration> get positionStream => _player.stream.position;
  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  // Video loading
  final _videoEntryController = StreamController<VideoEntry?>.broadcast();
  VideoEntry? _videoEntry;
  @override
  Stream<VideoEntry?> get videoEntryStream => _videoEntryController.stream;
  @override
  Future<void> open(VideoEntry entry) async {
    final httpHeaders = switch (entry.runtimeType) {
      const (BiliVideoEntry) || const (BiliBungumiEntry) => {
          'Referer': 'https://www.bilibili.com/'
        },
      const (AListEntry) => {'User-Agent': 'pan.baidu.com'},
      Type() => null,
    };

    // try every url
    bool success = false;
    for (var url in entry.sources.video) {
      await _player.open(
        media_kit.Media(url, httpHeaders: httpHeaders),
        play: false,
      );

      await Future.any([
        // Network timeout
        Future.delayed(const Duration(seconds: 6)),
        () async {
          // HACK: wait for video loaded
          // https://github.com/media-kit/media-kit/issues/228
          //await _player.stream.buffer.first;
          success = true;
        }(),
      ]);
      if (success) break;
      logger.w('Fail to open url $url, try next one');
    }
    if (!success) throw 'All source tested, no one success';

    // load audio if exist
    if (entry.sources.audio != null) {
      _mpvCommand('audio-add ${entry.sources.audio![0]} select audio');
    }

    _videoEntry = entry;
    _videoEntryController.add(_videoEntry);

    // load history watching progress
    if (_watchProgress.containsKey(entry.hash)) {
      seek(
        Duration(milliseconds: _watchProgress[entry.hash]!.progress),
      );
    } else {
      seek(Duration.zero);
    }

    windowManager.setTitle(entry.title);

    _statusController.add(PlayStatusType.pause);
  }

  // Play status
  final _statusController = StreamController<PlayStatusType>.broadcast();
  @override
  Stream<PlayStatusType> get statusStream =>
      _statusController.stream.distinct();
  @override
  Future<void> play() {
    _statusController.add(PlayStatusType.play);
    return _player.play();
  }

  @override
  Future<void> pause() {
    _statusController.add(PlayStatusType.pause);
    return _player.pause();
  }

  @override
  Future<void> stop() {
    final appName = getIt<PackageInfo>().appName;
    windowManager.setTitle(appName);

    _statusController.add(PlayStatusType.stop);

    _videoEntry = null;
    _videoEntryController.add(_videoEntry);

    return _player.stop();
  }

  // Audio tracks
  @override
  Future<void> setAudioTrackID(String id) {
    final audioTracks = _player.state.tracks.audio;
    final track = audioTracks.firstWhere((track) => track.id == id);
    return _player.setAudioTrack(track);
  }

  @override
  Stream<Iterable<AudioTrack>> get audioTracksStream => _player.stream.tracks
      .map((tracks) => tracks.audio)
      .distinct()
      .map<Iterable<AudioTrack>>(
        (list) => list.map(
          (track) => AudioTrack(track.id, track.title, track.language),
        ),
      );
  @override
  Stream<String> get currentAudioTrackID =>
      _player.stream.track.map((track) => track.audio.id).distinct();

  // Subtitle
  @override
  Future<void> setSubtitleTrackID(String id) {
    final subtitleTracks = _player.state.tracks.subtitle;
    final track = subtitleTracks.firstWhere((track) => track.id == id);
    return _player.setSubtitleTrack(track);
  }

  bool _waitingNewSub = false;
  @override
  Future<void> loadSubtitleTrack(String uri) async {
    _mpvCommand('sub-add "$uri" auto');
    _waitingNewSub = true;
  }

  @override
  Stream<Iterable<SubtitleTrack>> get subtitleTracksStream =>
      _player.stream.tracks
          .map((tracks) => tracks.subtitle)
          .distinct()
          .map<Iterable<SubtitleTrack>>(
            (list) => list.map(
              (track) => SubtitleTrack(track.id, track.title, track.language),
            ),
          )
          .asBroadcastStream();
  @override
  Stream<String> get currentSubtitleTrackID =>
      _player.stream.track.map((track) => track.subtitle.id).distinct();

  final _subDelayController = StreamController<double>.broadcast();
  @override
  Stream<double> get subDelayStream => _subDelayController.stream;
  @override
  Future<void> resetSubDelay() => setSubDelay(0);
  @override
  Future<void> setSubDelay(double delay) {
    _subDelayController.add(delay);
    return _setProperty('sub-delay', delay.toStringAsFixed(2));
  }

  final _subPosController = StreamController<int>.broadcast();
  @override
  Stream<int> get subPosStream => _subPosController.stream;
  @override
  Future<void> resetSubPos() => setSubPos(0);
  @override
  Future<void> setSubPos(int pos) {
    _subPosController.add(pos);
    pos = 100 - pos;
    return _setProperty('sub-pos', pos.toString());
  }

  final _subSizeController = StreamController<int>.broadcast();
  @override
  Stream<int> get subSizeStream => _subSizeController.stream;
  @override
  Future<void> resetSubSize() => setSubSize(Player.defaultSubSize);
  @override
  // FIXME: sub size and pos not work
  Future<void> setSubSize(int size) {
    _subSizeController.add(size);
    size += 5;
    return _setProperty('sub-font-size', size.toString());
  }

  // Contrast
  final _contrastController = StreamController<int>.broadcast();
  @override
  Stream<int> get contrastStream => _contrastController.stream;
  @override
  Future<void> resetContrast() => setContrast(0);
  @override
  Future<void> setContrast(int contrast) {
    _contrastController.add(contrast);
    return _setProperty('contrast', contrast.toString());
  }

  // Watch progress
  late final Map<String, WatchProgress> _watchProgress;
  @override
  Map<String, WatchProgress> get watchProgresses =>
      Map.unmodifiable(_watchProgress);
  void _loadWatchProgress() {
    final rawData = getIt<Preferences>().get<String>('watch_progress');

    try {
      final o = jsonDecode(rawData!);
      final d = Map.castFrom(o);
      _watchProgress =
          d.map((key, value) => MapEntry(key, WatchProgress.fromJson(value)));
    } catch (e) {
      logger.w('Load watch progress failed');
      _watchProgress = {};
    }

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_videoEntry != null) {
        _watchProgress[_videoEntry!.hash] = WatchProgress(
          progress: _player.state.position.inMilliseconds,
          duration: _player.state.duration.inMilliseconds,
        );
      }
    });

    AppLifecycleListener(
      onExitRequested: () async {
        // Save watch progress on exit
        await getIt<Preferences>().set(
          'watch_progress',
          jsonEncode(_watchProgress),
        );
        return AppExitResponse.exit;
      },
    );
  }

  void _setUpLogs() {
    statusStream.listen((status) {
      logger.i('Player: status hash changed to $status');
    });
    videoEntryStream.listen((videoHash) {
      logger.i('Player: video hash changed to $videoHash');
    });
    audioTracksStream.listen((tracks) {
      logger.i('Player: audio tracks changed:\n  ${tracks.join('\n  ')}');
    });
    subtitleTracksStream.listen((tracks) {
      logger.i('Player: subtitle tracks changed:\n  ${tracks.join('\n  ')}');
    });
  }

  Future<void> _setProperty(String key, String value) {
    final platfromPlayer = _player.platform!;
    if (platfromPlayer is media_kit.NativePlayer) {
      return platfromPlayer.setProperty(key, value);
    }
    throw Exception('Failed to set player property');
  }

  void _mpvCommand(String command) {
    final platfromPlayer = _player.platform;
    if (platfromPlayer is media_kit.NativePlayer) {
      command = command.replaceAll('\\', '\\\\');
      final mpv = platfromPlayer.mpv;
      final cmd = command.toNativeUtf8();
      mpv.mpv_command_string(platfromPlayer.ctx, cmd.cast());
      calloc.free(cmd);
    }
  }
}
