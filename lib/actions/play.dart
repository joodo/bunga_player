import 'package:bunga_player/singletons/im_video_connector.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:bunga_player/singletons/video_controller.dart';
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
      var volume = VideoController().volume.value + intent.amount;
      volume = volume > 100.0
          ? 100
          : volume < 0
              ? 0
              : volume;
      VideoController().volume.value = volume;
    } else {
      VideoController().volume.value = intent.amount;
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
      var position = VideoController().position.value + intent.duration;
      position = position > VideoController().duration.value
          ? VideoController().duration.value
          : position < Duration.zero
              ? Duration.zero
              : position;
      await VideoController().seekTo(position);
    } else {
      await VideoController().seekTo(intent.duration);
    }
    IMVideoConnector().sendPlayerStatus();
  }

  @override
  bool isEnabled(SetPositionIntent intent) =>
      !VideoController().isStopped.value;
}

class TogglePlayIntent extends Intent {
  const TogglePlayIntent();
}

class TogglePlayAction extends Action<TogglePlayIntent> {
  @override
  Future<void> invoke(TogglePlayIntent intent) async {
    await VideoController().togglePlay();
    IMVideoConnector().sendPlayerStatus();
  }

  @override
  bool isEnabled(TogglePlayIntent intent) => !VideoController().isStopped.value;
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
