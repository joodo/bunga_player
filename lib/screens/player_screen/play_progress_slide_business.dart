import 'package:async/async.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayProgressSlideBusiness {
  final BuildContext context;

  final _player = MediaPlayer.i;
  late final _playerPositionNotifier = _player.positionNotifier;

  final _positionNotifier = ValueNotifier<Duration>(Duration.zero);
  ValueListenable<Duration> get positionNotifier => _positionNotifier;

  final _isSeekingNotifier = ValueNotifier<bool>(false);
  ValueListenable<bool> get isSeekingNotifier => _isSeekingNotifier;

  void dispose() {
    _playerPositionNotifier.removeListener(_followPlayerPosition);
    _positionNotifier.dispose();
    _isSeekingNotifier.dispose();
    _seekTimer.cancel();
  }

  PlayProgressSlideBusiness({required this.context}) {
    _playerPositionNotifier.addListener(_followPlayerPosition);
  }

  void _followPlayerPosition() {
    _positionNotifier.value = _playerPositionNotifier.value;
  }

  late final RestartableTimer _seekTimer = RestartableTimer(
    const Duration(milliseconds: 5000),
    () {
      if (_player.durationNotifier.value != Duration.zero) {
        _player.seek(_positionNotifier.value);
      }
      _seekTimer.reset();
    },
  )..cancel();

  bool _isPlayingBeforeSlide = false;
  Duration _startValue = Duration.zero;

  void startSlide(Duration value) {
    _playerPositionNotifier.removeListener(_followPlayerPosition);

    Actions.maybeInvoke(context, SeekStartIntent());

    _isPlayingBeforeSlide = _player.playStatusNotifier.value.isPlaying;
    _player.pause();

    _positionNotifier.value = value;
    _startValue = value;
    _seekTimer.reset();

    final showHUDNotifier = context.read<ShouldShowHUDNotifier>();
    showHUDNotifier.lockUp('position drag');

    _isSeekingNotifier.value = true;
  }

  void updateSlide(Duration value) {
    _positionNotifier.value = value;
  }

  void finishSlide(Duration value) async {
    _isSeekingNotifier.value = false;

    _seekTimer.cancel();

    final showHUDNotifier = context.read<ShouldShowHUDNotifier>();
    showHUDNotifier.unlock('position drag');

    await _player.seek(value);

    if (_isPlayingBeforeSlide) await _player.play();

    _positionNotifier.value = value;
    _playerPositionNotifier.addListener(_followPlayerPosition);

    if (!context.mounted) return;
    Actions.maybeInvoke(context, SeekEndIntent());
  }

  void cancelSlide() async {
    _isSeekingNotifier.value = false;

    _seekTimer.cancel();

    final showHUDNotifier = context.read<ShouldShowHUDNotifier>();
    showHUDNotifier.unlock('position drag');

    await _player.seek(_startValue);
    if (_isPlayingBeforeSlide) await _player.play();

    _positionNotifier.value = _startValue;
    _playerPositionNotifier.addListener(_followPlayerPosition);
  }
}
