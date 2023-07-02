import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bunga_player/models/bili_entry.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:collection/collection.dart';
import 'package:crclib/catalog.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';

class VideoPlayer with WindowListener {
  static final emptyMedia = Media('asset:///assets/images/black.png');

  // Singleton
  static final _instance = VideoPlayer._internal();
  factory VideoPlayer() => _instance;

  late final _player = Player(
    configuration: const PlayerConfiguration(logLevel: MPVLogLevel.warn),
  )..open(emptyMedia, play: false);

  late final _controller = media_kit.VideoController(_player);
  media_kit.VideoController get controller => _controller;

  final duration = ReadonlyStreamNotifier<Duration>(Duration.zero);
  final buffer = ReadonlyStreamNotifier<Duration>(Duration.zero);
  final position = StreamNotifier<Duration>(Duration.zero);
  final isPlaying = StreamNotifier<bool>(false);
  final volume = ValueNotifier<double>(100.0);
  final isMute = ValueNotifier<bool>(false);
  final contrast = ValueNotifierWithReset<int>(0);
  final tracks = ReadonlyStreamNotifier<Tracks?>(null);
  final track = ReadonlyStreamNotifier<Track?>(null);

  final subDelay = ValueNotifierWithReset<double>(0.0); // sub-delay
  final subSize = ValueNotifierWithReset<double>(55.0); // sub-font-size
  final subPosition = ValueNotifierWithReset<double>(100.0); // sub-pos=<0-150>

  bool _isWaitingSubtitleLoaded = false;

  VideoPlayer._internal() {
    MediaKit.ensureInitialized();

    _initWatchProgress();

    // set mpv auto reconnect
    // from https://github.com/mpv-player/mpv/issues/5793#issuecomment-553877261
    _mpvProperty('stream-lavf-o', 'reconnect_streamed=1');

    duration.bind(_player.streams.duration);
    buffer.bind(_player.streams.buffer);
    position.bind(_player.streams.position, _player.seek);
    isPlaying.bind(_player.streams.playing, (play) {
      play ? _player.play() : _player.pause();
    });
    tracks.bind(_player.streams.tracks);
    track.bind(_player.streams.track);

    _player.streams.log.listen(
        (event) => logger.i('Player log: [${event.prefix}]${event.text}'));

    isPlaying.addListener(() {
      if (isPlaying.value) {
        Wakelock.enable();
      } else {
        Wakelock.disable();
      }
    });
    volume.addListener(() {
      isMute.value = false;
      _player.setVolume(volume.value);
    });
    isMute.addListener(() {
      if (isMute.value) {
        _player.setVolume(0);
      } else {
        _player.setVolume(volume.value);
      }
    });

    contrast
        .addListener(() => _mpvProperty('contrast', contrast.value.toString()));
    subDelay.addListener(
        () => _mpvProperty('sub-delay', subDelay.value.toStringAsFixed(2)));
    subSize.addListener(
        () => _mpvProperty('sub-font-size', subSize.value.toInt().toString()));
    subPosition.addListener(
        () => _mpvProperty('sub-pos', subPosition.value.toInt().toString()));

    // auto load new opened subtitle
    tracks.addListener(() {
      if (_isWaitingSubtitleLoaded) {
        final subtitleTrack = tracks.value!.subtitle.last;
        _player.setSubtitleTrack(subtitleTrack);
        _isWaitingSubtitleLoaded = false;
      }
    });

    windowManager.addListener(this);
  }

  final _videoHashNotifier = PrivateValueNotifier<String?>(null);
  late final videoHashNotifier = _videoHashNotifier.readonly;
  late final isStoppedNotifier = ProxyValueNotifier<bool, String?>(
    proxy: (originValue) => originValue == null,
    from: _videoHashNotifier,
  );

  Future<void> loadLocalVideo(String path) async {
    await _player.open(Media(path), play: false);
    await _controller.waitUntilFirstFrameRendered;

    final crcValue =
        await File(path).openRead().take(1000).transform(Crc32Xz()).single;
    final crcString = crcValue.toString();

    final videoHash = 'local-$crcString';
    if (_watchProgress.containsKey(videoHash)) {
      position.value = Duration(milliseconds: _watchProgress[videoHash]!);
    }

    _videoHashNotifier.value = videoHash;
  }

  Future<void> loadBiliVideo(BiliEntry biliEntry) async {
    bool success = false;

    for (var url in biliEntry.videoUrls) {
      if (url.startsWith('dash')) {
        final urls = url.split(';');
        await _player.open(
          Media(
            urls[1],
            httpHeaders: {'Referer': 'https://www.bilibili.com/'},
          ),
          play: false,
        );
        Future.delayed(
          const Duration(seconds: 1),
          () => addAudioTrack(urls[2]),
        );
      } else {
        await _player.open(
          Media(
            url,
            httpHeaders: {'Referer': 'https://www.bilibili.com/'},
          ),
          play: false,
        );
      }

      await Future.any([
        // HACK: To found whether network media open success
        Future.delayed(const Duration(seconds: 6)),
        () async {
          await _controller.waitUntilFirstFrameRendered;
          success = true;
        }(),
      ]);
      if (success) break;
      logger.w('Fail to open url $url, try next one');
    }

    if (!success) throw 'All source tested, no one success';

    final videoHash = biliEntry.hash;
    if (_watchProgress.containsKey(videoHash)) {
      // HACK: wait for seek
      await Future.delayed(const Duration(seconds: 1));
      position.value = Duration(milliseconds: _watchProgress[videoHash]!);
    }

    _videoHashNotifier.value = videoHash;
  }

  Future<void> stop() async {
    _player.pause();
    await _player.open(emptyMedia, play: false);
    await _controller.waitUntilFirstFrameRendered;
    _videoHashNotifier.value = null;
  }

  void setAudioTrack(String? id) {
    final audioTrack = tracks.value?.audio.firstWhereOrNull((e) => e.id == id);
    if (audioTrack == null) return;
    _player.setAudioTrack(audioTrack);
  }

  void setSubtitleTrack(String? id) {
    final subtitleTrack =
        tracks.value?.subtitle.firstWhereOrNull((e) => e.id == id);
    if (subtitleTrack == null) return;
    _player.setSubtitleTrack(subtitleTrack);
  }

  void addSubtitleTrack(String source) {
    _mpvCommand('sub-add "$source" auto');
    _isWaitingSubtitleLoaded = true;
  }

  void addAudioTrack(String source) {
    _mpvCommand('audio-add $source select audio');
  }

  void _mpvCommand(String command) {
    final mpvPlayer = _player.platform;
    if (mpvPlayer is libmpvPlayer) {
      command = command.replaceAll('\\', '\\\\');
      final mpv = mpvPlayer.mpv;
      final cmd = command.toNativeUtf8();
      mpv.mpv_command_string(mpvPlayer.ctx, cmd.cast());
      calloc.free(cmd);
    }
  }

  void _mpvProperty(String key, String value) {
    final mpvPlayer = _player.platform;
    if (mpvPlayer is libmpvPlayer) {
      mpvPlayer.setProperty(key, value);
    }
  }

  // Watch progress
  late final Map<String, int> _watchProgress;

  void _initWatchProgress() async {
    final pref = await SharedPreferences.getInstance();
    _watchProgress =
        Map.castFrom(jsonDecode(pref.getString('watch_progress') ?? '{}'));

    Timer.periodic(const Duration(seconds: 5), (timer) {
      final hash = videoHashNotifier.value;
      final progress = position.value;
      if (hash != null) {
        _watchProgress[hash] = progress.inMilliseconds;
      }
    });
  }

  @override
  // TODO: Should change to AppLifecycleListener
  // https://github.com/flutter/flutter/issues/30735
  void onWindowClose() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('watch_progress', jsonEncode(_watchProgress));
  }
}
