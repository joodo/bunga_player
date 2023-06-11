import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/logger.dart';
import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit_video;
import 'package:wakelock/wakelock.dart';

class VideoController {
  // Singleton
  static final _instance = VideoController._internal();
  factory VideoController() => _instance;

  late final _player = Player(
    configuration: const PlayerConfiguration(logLevel: MPVLogLevel.warn),
  );

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
  final isPlaying = ValueNotifier<bool>(false);
  final position = ValueNotifier<Duration>(Duration.zero);
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

  bool _isDraggingSlider = false;
  bool _isPlayingBeforeDraggingSlider = false;

  bool _isWaitingSubtitleLoaded = false;

  VideoController._internal() {
    MediaKit.ensureInitialized();

    _player.streams.log.listen(
        (event) => logger.i('Player log: [${event.prefix}]${event.text}'));

    _player.streams.position.listen((positionValue) {
      if (!_isDraggingSlider) {
        position.value = positionValue;
      }
    });

    duration.addListener(() {
      // HACK: remove this listener will cause duration always 0. WHY?!!
    });

    isPlaying.addListener(() {
      if (isPlaying.value) {
        _player.play();
        Wakelock.enable();
      } else {
        _player.pause();
        Wakelock.disable();
      }
      if (!_isDraggingSlider) IMController().sendPlayerStatus();
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

  Future<void> loadVideo(source) async {
    if (source is String) {
      // local file
      // HACK: Windows will fail if open instantly
      Future.delayed(const Duration(seconds: 1), () async {
        await _player.open(Media(source), play: false);
        await _controller.waitUntilFirstFrameRendered;
        IMController().askPosition();
      });
    } else if (source is List<String>) {
      // bilibili video urls
      for (var url in source) {
        await _player.open(
          Media(
            url,
            httpHeaders: {'Referer': 'https://www.bilibili.com/'},
          ),
          play: false,
        );

        bool success = true;
        await Future.any([
          () async {
            // HACK: To found whether network media open success
            // as player log level is WARN, there's no log if it's success
            await _player.streams.log.first;
            success = false;
          }(),
          _controller.waitUntilFirstFrameRendered,
        ]);
        if (success) return;

        logger.w('Fail to open source $source, try next one');
      }

      throw 'All source tested, no one success';
    } else {
      throw 'Unknown media source';
    }

    IMController().askPosition();
  }

  void togglePlay() {
    isPlaying.value = !isPlaying.value;
  }

  void jumpTo(Duration target) {
    position.value = target;
    _player.seek(target);
    IMController().sendPlayerStatus();
  }

  void onDraggingSliderStart(Duration positionValue) {
    _isDraggingSlider = true;
    _isPlayingBeforeDraggingSlider = isPlaying.value;
    isPlaying.value = false;
    position.value = positionValue;
  }

  void onDraggingSlider(Duration positionValue) {
    position.value = positionValue;
    _player.seek(positionValue);
  }

  void onDraggingSliderFinished(Duration positionValue) {
    position.value = positionValue;
    isPlaying.value = _isPlayingBeforeDraggingSlider;
    _isDraggingSlider = false;

    IMController().sendPlayerStatus();
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

class StreamNotifier<T> extends ValueListenable<T> {
  late final Stream<T> _stream;
  final List<VoidCallback> _listeners = [];
  late T _value;

  StreamNotifier({required T initialValue, required Stream<T> stream}) {
    _value = initialValue;
    _stream = stream;

    _stream.listen((value) {
      _value = value;
      for (var callback in _listeners) {
        callback.call();
      }
    });
  }

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  T get value => _value;
}

class ValueNotifierWithReset<T> extends ValueNotifier<T> {
  late T _initValue;

  ValueNotifierWithReset(T value) : super(value) {
    _initValue = value;
  }

  void reset() {
    value = _initValue;
  }
}
