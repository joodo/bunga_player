import 'package:flutter_meedu_videoplayer/meedu_player.dart';

class VideoController {
  static final _meeduPlayerController = MeeduPlayerController(
    controlsEnabled: false,
    showLogs: false,
  );
  static MeeduPlayerController instance() => _meeduPlayerController;
}
