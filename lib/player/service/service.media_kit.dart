import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/network/service.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' as media_kit;
import 'package:media_kit_video/media_kit_video.dart' as media_kit;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/watch_progress.dart';
import '../models/video_entries/video_entry.dart';
import 'service.dart';

class MediaKitPlayer implements Player {
  MediaKitPlayer() {
    media_kit.MediaKit.ensureInitialized();

    // set mpv auto reconnect
    // from https://github.com/mpv-player/mpv/issues/5793#issuecomment-553877261
    _setProperty('stream-lavf-o-append', 'reconnect_on_http_error=4xx,5xx');
    _setProperty('stream-lavf-o-append', 'reconnect_delay_max=30');
    _setProperty('stream-lavf-o-append', 'reconnect_streamed=yes');

    // Things when video finish
    _setProperty('keep-open', 'yes');
    _player.stream.playing.listen(
      (isPlay) {
        if (_player.state.playlist.medias.isEmpty) return;
        _statusController
            .add(isPlay ? PlayStatusType.play : PlayStatusType.pause);
      },
    );

    // Subtitles
    _setProperty('sub-visibility', 'yes'); // use mpv subtitle, not media_kit

    // Position
    _player.stream.position.listen(
      (position) => _positionStreamController.add(position),
    );

    // When video loaded
    _player.stream.duration.listen((duration) {
      if (duration <= Duration.zero) return;

      if (_seekCache != null) {
        _player.seek(_seekCache!);
        _seekCache = null;
      }
    });

    _player.stream.log.listen((log) => logger.w('Media kit log: ${log.text}'));

    _loadWatchProgress();
  }

  late final _player = media_kit.Player(
    configuration: const media_kit.PlayerConfiguration(
      logLevel: media_kit.MPVLogLevel.warn,
    ),
  );
  late final _widget = media_kit.Video(
    controller: media_kit.VideoController(_player),
    // use mpv subtitle
    subtitleViewConfiguration:
        const media_kit.SubtitleViewConfiguration(visible: false),
    wakelock: true,
    controls: media_kit.NoVideoControls,
  );
  @override
  Widget get videoWidget => _widget;

  // Volume
  Volume _volume = Volume(volume: Volume.max);
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
    _volume = Volume(volume: volume);
    _volumeController.add(_volume);
    return _player.setVolume(volume.toDouble());
  }

  // Buffer, Duration
  @override
  Stream<Duration> get bufferStream => _player.stream.buffer;
  @override
  Stream<Duration> get durationStream => _player.stream.duration;
  final _positionStreamController = StreamController<Duration>.broadcast();
  @override
  Stream<bool> get isBufferingStream => _player.stream.buffering;

  // Position
  @override
  Stream<Duration> get positionStream => _positionStreamController.stream;
  Duration? _seekCache; // For seek before video loaded
  @override
  Future<void> seek(Duration position) async {
    _positionStreamController.add(position);

    // whether video is loading
    if (_player.state.duration <= Duration.zero) {
      _seekCache = position;
    } else {
      return _player.seek(position);
    }
  }

  // Video loading
  final _sourceIndexController = StreamController<int?>.broadcast();
  @override
  Stream<int?> get sourceIndexStream => _sourceIndexController.stream;

  final _videoEntryController = StreamController<VideoEntry?>.broadcast();
  VideoEntry? _videoEntry;
  @override
  Stream<VideoEntry?> get videoEntryStream => _videoEntryController.stream;
  @override
  Future<void> open(VideoEntry entry, [int sourceIndex = 0]) async {
    assert(entry.sources.videos.length > sourceIndex);

    // Update stream
    _videoEntry = entry;
    _videoEntryController.add(_videoEntry);
    _sourceIndexController.add(sourceIndex);

    // Set headers
    final httpHeaders = switch (entry.runtimeType) {
      const (BiliVideoEntry) || const (BiliBungumiEntry) => {
          'Referer': 'https://www.bilibili.com/'
        },
      const (AListEntry) => {'User-Agent': 'pan.baidu.com'},
      Type() => null,
    };

    // open video
    final videoUrl = entry.sources.videos[sourceIndex];
    await _player.open(
      media_kit.Media(videoUrl, httpHeaders: httpHeaders),
      play: false,
    );

    // load saved progress
    if (_watchProgress.containsKey(entry.hash)) {
      seek(Duration(milliseconds: _watchProgress[entry.hash]!.progress));
    }

    // load audio if exist
    if (entry.sources.audios != null) {
      _mpvCommand('audio-add ${entry.sources.audios![0]} select audio');
    }

    // update play status
    _statusController.add(PlayStatusType.pause);
  }

  // Play status
  final _statusController = StreamController<PlayStatusType>.broadcast();
  @override
  Stream<PlayStatusType> get statusStream =>
      _statusController.stream.distinct();
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() async {
    await _player.pause();
    _saveCurrentProgress();
  }

  @override
  Future<void> toggle() => _player.playOrPause();

  @override
  Future<Uint8List?> screenshot() => _player.screenshot();

  @override
  Future<void> stop() {
    _saveCurrentProgress();

    _statusController.add(PlayStatusType.stop);

    _videoEntry = null;
    _videoEntryController.add(null);
    _sourceIndexController.add(null);

    return _player.stop();
  }

  @override
  Future<void> setRate(double rate) {
    return _player.setRate(rate);
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
    final track = subtitleTracks.firstWhere((track) =>
        track.id == id || (track.title?.startsWith(',$id,') ?? false));
    return _player.setSubtitleTrack(track);
  }

  int _externalSubIndex = 0;
  final _externalSubUris = <String, String>{};
  @override
  Future<SubtitleTrack> loadSubtitleTrack(String uri) async {
    final eid = 'e${_externalSubIndex++}';
    final title = path.basenameWithoutExtension(uri);

    _externalSubUris[eid] = uri;

    // Save network resource to local
    if (uri.startsWith('http')) {
      final tempDir = await getApplicationCacheDirectory();
      final localPath =
          '${tempDir.path}/subtitle-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
      await getIt<NetworkService>().downloadFile(uri, localPath).last;
      uri = localPath;
    }

    // See https://mpv.io/manual/master/#command-interface-sub-add
    _mpvCommand('sub-add "$uri" auto ",$eid,$title"');

    return await Future.any([
      () async {
        while (true) {
          final tracks = await subtitleTracksStream.first;
          final track = tracks.firstWhereOrNull((track) => track.id == eid);
          if (track != null) return track;
        }
      }(),
      () async {
        while (true) {
          final log = await _player.stream.log.first;
          if (log.text == 'Can not open external file $uri.') {
            throw Exception('Player: subtitle open failed: $uri');
          }
        }
      }(),
    ]);
  }

  @override
  Stream<Iterable<SubtitleTrack>> get subtitleTracksStream =>
      _player.stream.tracks
          .map((tracks) => tracks.subtitle)
          .distinct()
          .map<Iterable<SubtitleTrack>>(
            (list) => list.map(
              (track) {
                if (track.title?.startsWith(',') != true) {
                  return SubtitleTrack(
                    id: track.id,
                    title: track.title,
                    language: track.language,
                  );
                }

                final splits = track.title!.split(',');
                return SubtitleTrack(
                  id: splits[1],
                  title: splits[2],
                  uri: _externalSubUris[splits[1]],
                  language: track.language,
                );
              },
            ),
          )
          .asBroadcastStream();
  @override
  Stream<String> get currentSubtitleTrackID =>
      _player.stream.track.map((track) {
        final subtitle = track.subtitle;
        if (subtitle.title?.startsWith(',') != true) {
          return subtitle.id;
        } else {
          return subtitle.title!.split(',')[1];
        }
      }).distinct();

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
  WatchProgresses get watchProgresses => WatchProgresses(
        get: (videoEntryId) => _watchProgress[videoEntryId],
        count: () => _watchProgress.length,
        clearAll: _watchProgress.clear,
      );

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

    getIt<ExitCallbacks>().add(_saveWatchProgress);
  }

  void _saveCurrentProgress() {
    if (_videoEntry != null) {
      _watchProgress[_videoEntry!.hash] = WatchProgress(
        progress: _player.state.position.inMilliseconds,
        duration: _player.state.duration.inMilliseconds,
      );
    }
  }

  Future<void> _saveWatchProgress() async {
    _saveCurrentProgress();
    await getIt<Preferences>().set(
      'watch_progress',
      jsonEncode(_watchProgress),
    );
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
