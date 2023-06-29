import 'package:bunga_player/singletons/im_video_connector.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:bunga_player/singletons/video_player.dart';
import 'package:flutter/material.dart';

class SetVolumeIntent extends Intent {
  const SetVolumeIntent(this.amount, {this.isIncrease = false});
  final double amount;
  final bool isIncrease;
}

class SetVolumeAction extends Action<SetVolumeIntent> {
  @override
  void invoke(SetVolumeIntent intent) {
    if (intent.isIncrease) {
      var volume = VideoPlayer().volume.value + intent.amount;
      volume = volume > 100.0
          ? 100
          : volume < 0
              ? 0
              : volume;
      VideoPlayer().volume.value = volume;
    } else {
      VideoPlayer().volume.value = intent.amount;
    }
  }
}

class SetPositionIntent extends Intent {
  const SetPositionIntent(this.duration, {this.isIncrease = false});
  final Duration duration;
  final bool isIncrease;
}

class SetPositionAction extends Action<SetPositionIntent> {
  @override
  Future<void> invoke(SetPositionIntent intent) async {
    if (intent.isIncrease) {
      var position = VideoPlayer().position.value + intent.duration;
      position = position > VideoPlayer().duration.value
          ? VideoPlayer().duration.value
          : position < Duration.zero
              ? Duration.zero
              : position;
      await VideoPlayer().seekTo(position);
    } else {
      await VideoPlayer().seekTo(intent.duration);
    }
    IMVideoConnector().sendPlayerStatus();
  }

  @override
  bool isEnabled(SetPositionIntent intent) => !VideoPlayer().isStopped.value;
}

class TogglePlayIntent extends Intent {
  const TogglePlayIntent();
}

class TogglePlayAction extends Action<TogglePlayIntent> {
  @override
  Future<void> invoke(TogglePlayIntent intent) async {
    await VideoPlayer().togglePlay();
    IMVideoConnector().sendPlayerStatus();
  }

  @override
  bool isEnabled(TogglePlayIntent intent) => !VideoPlayer().isStopped.value;
}

class SetFullScreenIntent extends Intent {
  const SetFullScreenIntent(this.isFullScreen);
  final bool isFullScreen;
}

final bindings = <Type, Action<Intent>>{
  SetVolumeIntent: SetVolumeAction(),
  SetPositionIntent: SetPositionAction(),
  TogglePlayIntent: TogglePlayAction(),
  SetFullScreenIntent: CallbackAction<SetFullScreenIntent>(
    onInvoke: (SetFullScreenIntent intent) =>
        UINotifiers().isFullScreen.value = intent.isFullScreen,
  ),
};
