import 'package:bunga_player/common/fullscreen.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortcutsWrapper extends StatelessWidget {
  final Widget child;

  const ShortcutsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): VolumeIncrementIntent(10),
        SingleActivator(LogicalKeyboardKey.arrowDown):
            VolumeIncrementIntent(-10),
        SingleActivator(LogicalKeyboardKey.arrowLeft):
            PositionIncrementIntent(-5000),
        SingleActivator(LogicalKeyboardKey.arrowRight):
            PositionIncrementIntent(5000),
        SingleActivator(LogicalKeyboardKey.space): TogglePlayIntent(),
        SingleActivator(LogicalKeyboardKey.escape): FullScreenIntent(false),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          VolumeIncrementIntent: CallbackAction<VolumeIncrementIntent>(
            onInvoke: (VolumeIncrementIntent intent) {
              var volume = VideoController().volume.value + intent.amount;
              volume = volume > 100.0
                  ? 100
                  : volume < 0
                      ? 0
                      : volume;

              VideoController().volume.value = volume;
              return null;
            },
          ),
          PositionIncrementIntent: CallbackAction<PositionIncrementIntent>(
            onInvoke: (PositionIncrementIntent intent) {
              var position = Duration(
                  milliseconds:
                      VideoController().position.value.inMilliseconds +
                          intent.milliseconds);
              position = position > VideoController().duration.value
                  ? VideoController().duration.value
                  : position < Duration.zero
                      ? Duration.zero
                      : position;
              VideoController().jumpTo(position);
              return null;
            },
          ),
          TogglePlayIntent: CallbackAction<TogglePlayIntent>(
            onInvoke: (TogglePlayIntent intent) =>
                VideoController().togglePlay(),
          ),
          FullScreenIntent: CallbackAction<FullScreenIntent>(
            onInvoke: (FullScreenIntent intent) =>
                FullScreen().set(intent.isFullScreen),
          ),
        },
        child: child,
      ),
    );
  }
}

class VolumeIncrementIntent extends Intent {
  const VolumeIncrementIntent(this.amount);
  final double amount;
}

class PositionIncrementIntent extends Intent {
  const PositionIncrementIntent(this.milliseconds);
  final int milliseconds;
}

class TogglePlayIntent extends Intent {
  const TogglePlayIntent();
}

class FullScreenIntent extends Intent {
  const FullScreenIntent(this.isFullScreen);
  final bool isFullScreen;
}
