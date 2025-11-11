import 'dart:async';
import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart' as media_kit;
import 'package:media_kit_video/media_kit_video.dart' as media_kit;
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:bunga_player/services/permissions.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/network/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/models/volume.dart';

import '../models/play_payload.dart';
import '../models/track.dart';
import 'service.dart';

class MediaKitPlayService implements PlayService {
  MediaKitPlayService() {
    media_kit.MediaKit.ensureInitialized();

    getIt<Permissions>().requestVideoAndAudio();

    // set mpv auto reconnect
    // from https://github.com/mpv-player/mpv/issues/5793#issuecomment-553877261
    _setProperty('stream-lavf-o-append', 'reconnect_on_http_error=4xx,5xx');
    _setProperty('stream-lavf-o-append', 'reconnect_delay_max=30');
    _setProperty('stream-lavf-o-append', 'reconnect_streamed=yes');

    // Things when video finish
    _setProperty('keep-open', 'yes');

    // Subtitles
    _setProperty('sub-visibility', 'yes'); // use mpv subtitle, not media_kit

    // Cache
    _setProperty('cache-on-disk', 'yes');

    // When video loaded
    _player.stream.duration.listen((duration) {
      if (duration <= Duration.zero) return;

      if (_seekCache != null) {
        _clampSeek(_seekCache!);
        _seekCache = null;
      }
    });

    // Initiate lazy value
    volumeNotifier;
    audioTrackNotifier;
    audioTracksNotifier;
    subtitleTrackNotifier;
    subtitleTracksNotifier;
    playStatusNotifier;
    bufferNotifier;
    durationNotifier;
    isBufferingNotifier;
    positionNotifier;
    proxyNotifier;

    // Log
    _player.stream.log.listen((log) => logger.w('Media kit log: ${log.text}'));
  }

  late final _player = media_kit.Player(
    configuration: const media_kit.PlayerConfiguration(
      logLevel: media_kit.MPVLogLevel.warn,
    ),
  );
  late final controller = media_kit.VideoController(_player);

  // Volume
  @override
  late final volumeNotifier = ValueNotifier<Volume>(
    Volume(volume: Volume.max),
  )..addListener(() {
      final target =
          volumeNotifier.value.mute ? 0 : volumeNotifier.value.volume;
      _player.setVolume(target.toDouble());
    });

  // Buffer, Duration
  @override
  late final bufferNotifier = _StreamListenable(
    _player.stream.buffer,
    Duration.zero,
  );
  @override
  late final durationNotifier = _StreamListenable(
    _player.stream.duration,
    Duration.zero,
  );
  @override
  late final isBufferingNotifier = _StreamListenable(
    _player.stream.buffering,
    false,
  );

  // Position
  Duration? _seekCache; // For seek before video loaded
  @override
  late final positionNotifier = _StreamValueNotifier<Duration>(
    stream: _player.stream.position,
    setter: (position) {
      // whether video is loading
      if (_player.state.duration <= Duration.zero) {
        _seekCache = position;
      } else {
        _clampSeek(position);
      }
    },
    initValue: Duration.zero,
  );
  @override
  void seek(Duration position) => positionNotifier.value = position;
  void _clampSeek(Duration position) {
    position = position.clamp(Duration.zero, _player.state.duration);
    _player.seek(position);
  }

  // Video loading
  @override
  Future<void> open(PlayPayload payload) async {
    assert(payload.sources.videos.length > payload.videoSourceIndex);

    // open video
    final videoUrl = payload.sources.videos[payload.videoSourceIndex];
    final httpHeaders = payload.sources.requestHeaders;
    await _player.open(
      media_kit.Media(videoUrl, httpHeaders: httpHeaders),
      play: false,
    );

    // load audio
    if (payload.sources.audios != null) {
      if (httpHeaders != null) {
        final headerString =
            httpHeaders.entries.map((e) => '${e.key}=${e.value}').join(',');
        _setProperty('http-header-fields', '"$headerString"');
        await Future.delayed(const Duration(milliseconds: 300));
      }
      final audio = payload.sources.audios![0];
      _mpvCommand('audio-add $audio select auto');
    }

    // Avoid open after stop, play status keep Stop
    playStatusNotifier.value = PlayStatus.pause;
  }

  // Play status
  @override
  late final playStatusNotifier = _StreamValueNotifier<PlayStatus>(
    stream: _player.stream.playing
        .map((playing) => playing ? PlayStatus.play : PlayStatus.pause)
        .distinct(),
    setter: (playStatus) {
      switch (playStatus) {
        case PlayStatus.play:
          _player.play();
        case PlayStatus.pause:
          _player.pause();
        case PlayStatus.stop:
          _player.stop();
      }
    },
    initValue: PlayStatus.stop,
  );

  @override
  void play() => playStatusNotifier.value = PlayStatus.play;
  @override
  void pause() => playStatusNotifier.value = PlayStatus.pause;
  @override
  void toggle() =>
      playStatusNotifier.value == PlayStatus.play ? pause() : play();
  @override
  void stop() => playStatusNotifier.value = PlayStatus.stop;

  // Screenshot
  @override
  Future<Uint8List?> screenshot() => _player.screenshot();

  // Audio tracks
  @override
  late final audioTrackNotifier = _StreamValueNotifier<AudioTrack>(
    stream: _player.stream.track
        .map((track) => AudioTrack(
              track.audio.id,
              track.audio.title,
              track.audio.language,
            ))
        .distinct(),
    setter: (audioTrack) {
      final audioTracks = _player.state.tracks.audio;
      final track =
          audioTracks.firstWhere((track) => track.id == audioTrack.id);
      _player.setAudioTrack(track);
    },
    initValue: AudioTrack('none'),
  );

  @override
  late final audioTracksNotifier = _StreamValueNotifier<Iterable<AudioTrack>>(
    stream: _player.stream.tracks
        .map((tracks) => tracks.audio)
        .distinct()
        .map<Iterable<AudioTrack>>(
          (list) => list.map(
            (track) => AudioTrack(track.id, track.title, track.language),
          ),
        ),
    setter: (newValue) => throw UnimplementedError(),
    initValue: [],
  );

  // Subtitle
  @override
  late final subtitleTrackNotifier = _StreamValueNotifier<SubtitleTrack>(
    stream: _player.stream.track.map((track) {
      final subtitle = track.subtitle;
      if (subtitle.title?.startsWith(',') != true) {
        return SubtitleTrack(
          id: subtitle.id,
          title: subtitle.title,
          language: subtitle.language,
        );
      } else {
        final splits = subtitle.title!.split(',');
        return SubtitleTrack(
          id: splits[1],
          title: splits[2],
          language: subtitle.language,
          path: _externalSubPaths[splits[1]],
        );
      }
    }).distinct(),
    setter: (subtitleTrack) {
      final id = subtitleTrack.id;
      setSubtitleTrack(id);
    },
    initValue: SubtitleTrack(id: 'none'),
  );
  @override
  SubtitleTrack setSubtitleTrack(String id) {
    final subtitleTracks = _player.state.tracks.subtitle;
    final track = subtitleTracks.firstWhere((track) =>
        track.id == id || (track.title?.startsWith(',$id,') ?? false));
    _player.setSubtitleTrack(track);
    return subtitleTracksNotifier.value
        .firstWhere((element) => element.id == id);
  }

  late final _subtitleTracksStream = _player.stream.tracks
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
              path: _externalSubPaths[splits[1]],
              language: track.language,
            );
          },
        ),
      )
      .asBroadcastStream();
  @override
  late final subtitleTracksNotifier =
      _StreamValueNotifier<Iterable<SubtitleTrack>>(
    stream: _subtitleTracksStream,
    setter: (newValue) => throw UnimplementedError(),
    initValue: [],
  );

  int _externalSubIndex = 0;
  final _externalSubPaths = <String, String>{};
  @override
  Future<SubtitleTrack> loadSubtitleTrack(String uri) async {
    final title = path.basenameWithoutExtension(uri);
    late final String eid;
    if (uri.startsWith('http')) {
      // Save network resource to local
      final tempDir = await getApplicationCacheDirectory();
      final localPath =
          '${tempDir.path}/subtitle-${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
      await getIt<NetworkService>().downloadFile(uri, localPath).last;
      uri = localPath;

      eid = '\$n${_externalSubIndex++}';
    } else {
      eid = '\$e${_externalSubIndex++}';
    }

    _externalSubPaths[eid] = uri;

    // See https://mpv.io/manual/master/#command-interface-sub-add
    _mpvCommand('sub-add "$uri" auto ",$eid,$title"');

    return await Future.any([
      () async {
        while (true) {
          final tracks = await _subtitleTracksStream.first;
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

  // Subtitle tune
  @override
  late final subDelayNotifier = ValueNotifier<double>(0.0)
    ..addListener(() {
      _setProperty('sub-delay', subDelayNotifier.value.toStringAsFixed(2));
    });
  @override
  late final subSizeNotifier = ValueNotifier<double>(38.0)
    ..addListener(() {
      _setProperty('sub-font-size', subSizeNotifier.value.toInt().toString());
    });
  @override
  late final subPosNotifier = ValueNotifier<double>(0.0)
    ..addListener(() {
      final pos = subPosNotifier.value.toInt() + 100;
      _setProperty('sub-pos', pos.clamp(0, 150).toString());
    });

  // Brightness
  @override
  late final brightnessNotifier = ValueNotifier<int>(0)
    ..addListener(() {
      _setProperty('brightness', brightnessNotifier.value.toString());
    });
  // Contrast
  @override
  late final contrastNotifier = ValueNotifier<int>(0)
    ..addListener(() {
      _setProperty('contrast', contrastNotifier.value.toString());
    });
  // Saturation
  @override
  late final saturationNotifier = ValueNotifier<int>(0)
    ..addListener(() {
      _setProperty('saturation', saturationNotifier.value.toString());
    });
  // Gamma
  @override
  late final gammaNotifier = ValueNotifier<int>(0)
    ..addListener(() {
      _setProperty('gamma', gammaNotifier.value.toString());
    });
  // Hue
  @override
  late final hueNotifier = ValueNotifier<int>(0)
    ..addListener(() {
      _setProperty('hue', hueNotifier.value.toString());
    });

  // Proxy
  @override
  late final proxyNotifier = ValueNotifier<String?>(null)
    ..addListener(
      () {
        final proxy = proxyNotifier.value;
        if (proxy == null || proxy.isEmpty) {
          _setProperty('http-proxy', '');
        } else {
          _setProperty('http-proxy', 'http://$proxy');
        }
      },
    );

  void setCacheSize(int sizeInMB) {
    _setProperty('demuxer-max-bytes', '${sizeInMB}MiB');
  }

  // MPV command
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

class _StreamValueNotifier<T> extends ValueNotifier<T> {
  late final StreamSubscription _subscription;
  _StreamValueNotifier({
    required Stream<T> stream,
    required void Function(T newValue) setter,
    required T initValue,
  }) : super(initValue) {
    _subscription = stream.listen((data) {
      _oldValue = data;
      value = data;
    });
    addListener(() {
      if (_oldValue != value) {
        _oldValue = value;
        setter(value!);
      }
    });
  }

  T? _oldValue;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _StreamListenable<T> extends ChangeNotifier
    implements ValueListenable<T> {
  late final StreamSubscription _subscription;
  T _value;

  _StreamListenable(Stream<T> stream, T initValue) : _value = initValue {
    _subscription = stream.listen((newValue) {
      if (newValue == _value) return;

      _value = newValue;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  T get value => _value;
}
