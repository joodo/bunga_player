import 'dart:io';

import 'package:bunga_player/common/bili_video.dart';
import 'package:bunga_player/singletons/logger.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:collection/collection.dart';
import 'package:crclib/catalog.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit_video;
import 'package:wakelock/wakelock.dart';

class VideoController {
  static final emptyMedia = Media('asset:///assets/images/black.png');

  // Singleton
  static final _instance = VideoController._internal();
  factory VideoController() => _instance;

  late final _player = Player(
    configuration: const PlayerConfiguration(logLevel: MPVLogLevel.warn),
  )..open(emptyMedia, play: false);

  late final _controller = media_kit_video.VideoController(_player);
  late final _video = media_kit_video.Video(controller: _controller);
  media_kit_video.Video get video => _video;

  late final duration = StreamNotifier<Duration>(
    initialValue: Duration.zero,
    stream: _player.streams.duration,
  );
  late final buffer = StreamNotifier<Duration>(
    initialValue: Duration.zero,
    stream: _player.streams.buffer,
  );
  late final position = StreamNotifier<Duration>(
    initialValue: Duration.zero,
    stream: _player.streams.position,
  );
  late final isPlaying = StreamNotifier<bool>(
    initialValue: false,
    stream: _player.streams.playing,
  );

  // Don't use StreamNotifier for faster UI response
  final volume = ValueNotifier<double>(100.0);
  final isMute = ValueNotifier<bool>(false);
  final contrast = ValueNotifierWithReset<int>(0);

  late final tracks = StreamNotifier<Tracks?>(
    initialValue: null,
    stream: _player.streams.tracks,
  );
  late final track = StreamNotifier<Track?>(
    initialValue: null,
    stream: _player.streams.track,
  );

  final subDelay = ValueNotifierWithReset<double>(0.0); // sub-delay
  final subSize = ValueNotifierWithReset<double>(55.0); // sub-font-size
  final subPosition = ValueNotifierWithReset<double>(100.0); // sub-pos=<0-150>

  bool _isWaitingSubtitleLoaded = false;

  VideoController._internal() {
    MediaKit.ensureInitialized();

    // set mpv auto reconnect
    // from https://github.com/mpv-player/mpv/issues/5793#issuecomment-553877261
    final mpvPlayer = _player.platform;
    if (mpvPlayer is libmpvPlayer) {
      mpvPlayer.setProperty('stream-lavf-o', 'reconnect_streamed=1');
    }

    _player.streams.log.listen(
        (event) => logger.i('Player log: [${event.prefix}]${event.text}'));

    duration.addListener(() {
      // HACK: remove this listener will cause duration always 0. WHY?!!
    });

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

    contrast.addListener(() {
      final mpvPlayer = _player.platform;
      if (mpvPlayer is libmpvPlayer) {
        mpvPlayer.setProperty('contrast', contrast.value.toString());
      }
    });

    // auto load new opened subtitle
    tracks.addListener(() {
      if (_isWaitingSubtitleLoaded) {
        final subtitleTrack = tracks.value!.subtitle.last;
        _player.setSubtitleTrack(subtitleTrack);
        _isWaitingSubtitleLoaded = false;
      }
    });

    subDelay.addListener(() {
      final mpvPlayer = _player.platform;
      if (mpvPlayer is libmpvPlayer) {
        mpvPlayer.setProperty('sub-delay', subDelay.value.toStringAsFixed(2));
      }
    });
    subSize.addListener(() {
      final mpvPlayer = _player.platform;
      if (mpvPlayer is libmpvPlayer) {
        mpvPlayer.setProperty(
            'sub-font-size', subSize.value.toInt().toString());
      }
    });
    subPosition.addListener(() {
      final mpvPlayer = _player.platform;
      if (mpvPlayer is libmpvPlayer) {
        mpvPlayer.setProperty('sub-pos', subPosition.value.toInt().toString());
      }
    });
  }

  final _videoHashNotifier = ValueNotifier<String?>(null);
  late final videoHashNotifier = ProxyValueNotifier<String?, String?>(
    initialValue: null,
    proxy: (p0) => p0,
    from: _videoHashNotifier,
  );
  late final isStopped = ProxyValueNotifier<bool, String?>(
    initialValue: true,
    proxy: (originValue) => originValue == null,
    from: _videoHashNotifier,
  );

  Future<void> loadLocalVideo(String path) async {
    await _player.open(Media(path), play: false);
    await _controller.waitUntilFirstFrameRendered;

    final crcValue =
        await File(path).openRead().take(1000).transform(Crc32Xz()).single;
    final crcString = crcValue.toString();
    _videoHashNotifier.value = 'local-$crcString';
  }

  Future<String> loadBiliVideo(BiliVideo biliVideo) async {
    bool success = false;

    for (var url in biliVideo.videoUrls) {
      await _player.open(
        Media(
          url,
          httpHeaders: {'Referer': 'https://www.bilibili.com/'},
        ),
        play: false,
      );

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

    _videoHashNotifier.value = 'bili-${biliVideo.bvid}-${biliVideo.p}';
    return _videoHashNotifier.value!;
  }

  Future<void> togglePlay() => _player.playOrPause();
  Future<void> pause() => _player.pause();
  Future<void> play() => _player.play();
  Future<void> seekTo(Duration target) => _player.seek(target);

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
    final mpvPlayer = _player.platform;
    if (mpvPlayer is libmpvPlayer) {
      source = source.replaceAll('\\', '\\\\');
      final mpv = mpvPlayer.mpv;
      final command = 'sub-add "$source" auto'.toNativeUtf8();
      mpv.mpv_command_string(mpvPlayer.ctx, command.cast());
      calloc.free(command);
      _isWaitingSubtitleLoaded = true;
    }
  }
}
