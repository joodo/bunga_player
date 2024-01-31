import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/providers/ui/ui.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetVolumeIntent extends Intent {
  const SetVolumeIntent(this.amount, {this.isIncrease = false});
  final double amount;
  final bool isIncrease;
}

class SetVolumeAction extends ContextAction<SetVolumeIntent> {
  @override
  void invoke(SetVolumeIntent intent, [BuildContext? context]) {
    final videoPlayer = context!.read<VideoPlayer>();
    if (intent.isIncrease) {
      var volume = videoPlayer.volume.value + intent.amount;
      volume = volume > 100.0
          ? 100
          : volume < 0
              ? 0
              : volume;
      videoPlayer.volume.value = volume;
    } else {
      videoPlayer.volume.value = intent.amount;
    }
  }
}

class SetPositionIntent extends Intent {
  const SetPositionIntent(this.duration, {this.isIncrease = false});
  final Duration duration;
  final bool isIncrease;
}

class SetPositionAction extends ContextAction<SetPositionIntent> {
  @override
  void invoke(SetPositionIntent intent, [BuildContext? context]) {
    final videoPlayer = context!.read<VideoPlayer>();
    final playerController = context.read<RemotePlaying>();
    if (intent.isIncrease) {
      var position = videoPlayer.position.value + intent.duration;
      position = position > videoPlayer.duration.value
          ? videoPlayer.duration.value
          : position < Duration.zero
              ? Duration.zero
              : position;
      videoPlayer.position.value = position;
    } else {
      videoPlayer.position.value = intent.duration;
    }
    playerController.sendPlayerStatus();
  }

  @override
  bool isEnabled(SetPositionIntent intent, [BuildContext? context]) =>
      !context!.read<VideoPlayer>().isStoppedNotifier.value;
}

class TogglePlayIntent extends Intent {
  const TogglePlayIntent();
}

class TogglePlayAction extends ContextAction<TogglePlayIntent> {
  @override
  void invoke(TogglePlayIntent intent, [BuildContext? context]) {
    final videoPlayer = context!.read<VideoPlayer>();
    final playerController = context.read<RemotePlaying>();
    videoPlayer.isPlaying.value = !videoPlayer.isPlaying.value;
    playerController.sendPlayerStatus();
  }

  @override
  bool isEnabled(TogglePlayIntent intent, [BuildContext? context]) {
    final videoPlayer = context!.read<VideoPlayer>();
    final playerController = context.read<RemotePlaying>();
    return !videoPlayer.isStoppedNotifier.value &&
        !playerController.justToggledByRemote;
  }
}

class SetFullScreenIntent extends Intent {
  const SetFullScreenIntent(this.isFullScreen);
  final bool isFullScreen;
}

class SetFullScreenAction extends ContextAction<SetFullScreenIntent> {
  @override
  void invoke(SetFullScreenIntent intent, [BuildContext? context]) {
    context!.read<IsFullScreen>().value = intent.isFullScreen;
    context.read<IsControlSectionHidden>().value = false;
  }
}

final bindings = <Type, Action<Intent>>{
  SetVolumeIntent: SetVolumeAction(),
  SetPositionIntent: SetPositionAction(),
  TogglePlayIntent: TogglePlayAction(),
  SetFullScreenIntent: SetFullScreenAction(),
};
