import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit_video;
import 'package:wakelock/wakelock.dart';

class VideoController {
  // Singleton
  static final _instance = VideoController._internal();
  factory VideoController() => _instance;

  late final _player = Player();
  media_kit_video.VideoController get controller =>
      media_kit_video.VideoController(_player);

  final source = ValueNotifier<String?>(null);

  late final duration = StreamNotifier<Duration>(
    Duration.zero,
    _player.streams.duration,
  );
  final isPlaying = ValueNotifier<bool>(false);
  final position = ValueNotifier<Duration>(Duration.zero);
  final volume = ValueNotifier<double>(100.0);
  final isMute = ValueNotifier<bool>(false);
  final contrast = ValueNotifier<int>(0);

  bool _isDraggingSlider = false;
  bool _isPlayingBeforeDraggingSlider = false;

  VideoController._internal() {
    MediaKit.ensureInitialized();

    source.addListener(() {
      if (source.value != null) {
        _player.open(
          Media(source.value!),
          play: false,
        );
      }
    });

    _player.streams.position.listen((positionValue) {
      if (!_isDraggingSlider) {
        position.value = positionValue;
      }
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
}
