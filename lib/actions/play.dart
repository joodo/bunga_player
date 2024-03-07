import 'package:bunga_player/actions/dispatcher.dart';
import 'package:bunga_player/actions/ui.dart';
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/services/player.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class SetVolumeIntent extends Intent {
  const SetVolumeIntent(this.volume, {this.byKey = false});
  final int volume;
  final bool byKey;
}

class SetVolumeAction extends ContextAction<SetVolumeIntent> {
  @override
  Future<void> invoke(SetVolumeIntent intent, [BuildContext? context]) {
    var volume = intent.volume;
    if (intent.byKey) {
      volume += context!.read<PlayVolume>().volume;
      context.read<JustAdjustedVolumeByKey>().mark();
    }
    return getIt<Player>().setVolume(volume);
  }
}

class SetMuteIntent extends Intent {
  final bool mute;

  const SetMuteIntent(this.mute);
}

class SetMuteAction extends Action<SetMuteIntent> {
  @override
  Future<void> invoke(SetMuteIntent intent) {
    return getIt<Player>().setMute(intent.mute);
  }
}

class TogglePlayIntent extends Intent {
  const TogglePlayIntent();
}

class TogglePlayAction extends ContextAction<TogglePlayIntent> {
  @override
  Future<void>? invoke(TogglePlayIntent intent, [BuildContext? context]) {
    final read = context!.read;

    final playStatus = read<PlayStatus>();
    final position = read<PlayPosition>();
    Actions.maybeInvoke(
      context,
      SendPlayingStatusIntent(
        !playStatus.isPlaying ? PlayStatusType.play : PlayStatusType.pause,
        position.value.inMilliseconds,
      ),
    );

    return getIt<Player>().toggle();
  }

  @override
  bool isEnabled(TogglePlayIntent intent, [BuildContext? context]) {
    final read = context!.read;
    final isStopped = read<PlayStatus>().value == PlayStatusType.stop;
    final isToggledByRemote = read<JustToggleByRemote>().value;
    return !isStopped && !isToggledByRemote;
  }
}

class StopPlayIntent extends Intent {}

class StopPlayAction extends ContextAction<StopPlayIntent> {
  @override
  Future<void> invoke(StopPlayIntent intent, [BuildContext? context]) {
    Actions.invoke(context!, const SetWindowTitleIntent());
    return getIt<Player>().stop();
  }
}

class SeekIntent extends Intent {
  const SeekIntent(this.duration, {this.isIncrease = false});
  final Duration duration;
  final bool isIncrease;
}

class SeekAction extends ContextAction<SeekIntent> {
  @override
  Future<void>? invoke(SeekIntent intent, [BuildContext? context]) {
    final read = context!.read;

    final position = read<PlayPosition>();
    var newPos = intent.duration;
    if (intent.isIncrease) newPos += position.value;

    newPos = newPos.clamp(Duration.zero, read<PlayDuration>().value);
    getIt<Player>().seek(newPos);

    return Actions.maybeInvoke(
      context,
      SendPlayingStatusIntent(
        read<PlayStatus>().value,
        newPos.inMilliseconds,
      ),
    ) as Future<void>?;
  }

  @override
  bool isEnabled(SeekIntent intent, [BuildContext? context]) =>
      context!.read<PlayStatus>().value != PlayStatusType.stop;
}

class DragBusiness {
  bool isPlayingBeforeDraggingSlider = false;
}

class StartDraggingProgressIntent extends Intent {
  final Duration position;

  const StartDraggingProgressIntent(this.position);
}

class StartDraggingProgressAction
    extends ContextAction<StartDraggingProgressIntent> {
  final DragBusiness dragBusiness;

  StartDraggingProgressAction({required this.dragBusiness});

  @override
  void invoke(StartDraggingProgressIntent intent, [BuildContext? context]) {
    final read = context!.read;

    dragBusiness.isPlayingBeforeDraggingSlider = read<PlayStatus>().isPlaying;
    getIt<Player>().pause();

    final position = read<PlayPosition>();
    position.stopListenStream = true;
    position.seekTo(intent.position);

    getIt<Player>().seek(intent.position);
  }

  @override
  bool isEnabled(StartDraggingProgressIntent intent, [BuildContext? context]) =>
      context!.read<PlayStatus>().value != PlayStatusType.stop;
}

class DraggingProgressIntent extends Intent {
  final Duration position;

  const DraggingProgressIntent(this.position);
}

class DraggingProgressAction extends ContextAction<DraggingProgressIntent> {
  final DragBusiness dragBusiness;
  DraggingProgressAction({required this.dragBusiness});

  @override
  void invoke(DraggingProgressIntent intent, [BuildContext? context]) {
    final position = context!.read<PlayPosition>();
    position.seekTo(intent.position);

    getIt<Player>().seek(intent.position);
  }

  @override
  bool isEnabled(DraggingProgressIntent intent, [BuildContext? context]) {
    final read = context!.read;
    final isStopped = read<PlayStatus>().value == PlayStatusType.stop;
    final isDragging = read<PlayPosition>().stopListenStream;
    return !isStopped && isDragging;
  }
}

class FinishDraggingProgressIntent extends Intent {
  final Duration position;
  const FinishDraggingProgressIntent(this.position);
}

class FinishDraggingProgressAction
    extends ContextAction<FinishDraggingProgressIntent> {
  final DragBusiness dragBusiness;

  FinishDraggingProgressAction({required this.dragBusiness});

  @override
  Future<void>? invoke(FinishDraggingProgressIntent intent,
      [BuildContext? context]) async {
    final read = context!.read;
    Actions.maybeInvoke(
      context,
      SendPlayingStatusIntent(
        dragBusiness.isPlayingBeforeDraggingSlider
            ? PlayStatusType.play
            : PlayStatusType.pause,
        intent.position.inMilliseconds,
      ),
    );

    final position = read<PlayPosition>();
    position.seekTo(intent.position);
    position.stopListenStream = false;

    await getIt<Player>().seek(intent.position);
    if (dragBusiness.isPlayingBeforeDraggingSlider) {
      await getIt<Player>().play();
    }
  }

  @override
  bool isEnabled(FinishDraggingProgressIntent intent, [BuildContext? context]) {
    final read = context!.read;
    final isStopped = read<PlayStatus>().value == PlayStatusType.stop;
    final isDragging = read<PlayPosition>().stopListenStream;
    return !isStopped && isDragging;
  }
}

class SetAudioTrackIntent extends Intent {
  final String id;

  const SetAudioTrackIntent(this.id);
}

class SetAudioTrackAction extends Action<SetAudioTrackIntent> {
  @override
  Future<void> invoke(SetAudioTrackIntent intent) =>
      getIt<Player>().setAudioTrackID(intent.id);
}

class SetSubtitleIntent extends Intent {
  final String? id;
  final String? path;
  const SetSubtitleIntent.byID(this.id) : path = null;
  const SetSubtitleIntent.byPath(this.path) : id = null;
}

class SetSubtitleAction extends Action<SetSubtitleIntent> {
  @override
  Future<void> invoke(SetSubtitleIntent intent) {
    final player = getIt<Player>();

    if (intent.id != null) {
      return player.setSubtitleTrackID(intent.id!);
    } else {
      return player.loadSubtitleTrack(intent.path!);
    }
  }
}

class SetSubDelayIntent extends Intent {
  final double? delay;
  const SetSubDelayIntent([this.delay]);
}

class SetSubDelayAction extends Action<SetSubDelayIntent> {
  @override
  Future<void> invoke(SetSubDelayIntent intent) => intent.delay != null
      ? getIt<Player>().setSubDelay(intent.delay!)
      : getIt<Player>().resetSubDelay();
}

class SetSubSizeIntent extends Intent {
  final int? size;

  const SetSubSizeIntent([this.size]);
}

class SetSubSizeAction extends Action<SetSubSizeIntent> {
  @override
  Future<void> invoke(SetSubSizeIntent intent) => intent.size != null
      ? getIt<Player>().setSubSize(intent.size!)
      : getIt<Player>().resetSubSize();
}

class SetSubPosIntent extends Intent {
  final int? pos;

  const SetSubPosIntent([this.pos]);
}

class SetSubPosAction extends Action<SetSubPosIntent> {
  @override
  Future<void> invoke(SetSubPosIntent intent) => intent.pos != null
      ? getIt<Player>().setSubPos(intent.pos!)
      : getIt<Player>().resetSubPos();
}

class SetContrastIntent extends Intent {
  final int? contrast;
  const SetContrastIntent([this.contrast]);
}

class SetContrastAction extends Action<SetContrastIntent> {
  @override
  Future<void> invoke(SetContrastIntent intent) => intent.contrast != null
      ? getIt<Player>().setContrast(intent.contrast!)
      : getIt<Player>().resetContrast();
}

class PlayActions extends SingleChildStatefulWidget {
  const PlayActions({super.key, super.child});

  @override
  State<PlayActions> createState() => _PlayActionsState();
}

class _PlayActionsState extends SingleChildState<PlayActions> {
  final _dragBusiness = DragBusiness();

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final shortcuts = Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp):
            SetVolumeIntent(10, byKey: true),
        SingleActivator(LogicalKeyboardKey.arrowDown):
            SetVolumeIntent(-10, byKey: true),
        SingleActivator(LogicalKeyboardKey.arrowLeft):
            SeekIntent(Duration(seconds: -5), isIncrease: true),
        SingleActivator(LogicalKeyboardKey.arrowRight):
            SeekIntent(Duration(seconds: 5), isIncrease: true),
        SingleActivator(LogicalKeyboardKey.space): TogglePlayIntent(),
      },
      child: child!,
    );

    return Actions(
      dispatcher: LoggingActionDispatcher(
        prefix: 'play',
        mute: {
          SetVolumeIntent,
          DraggingProgressIntent,
          SetSubDelayIntent,
          SetSubSizeIntent,
          SetSubPosIntent,
          SetContrastIntent,
        },
      ),
      actions: <Type, Action<Intent>>{
        SetVolumeIntent: SetVolumeAction(),
        SetMuteIntent: SetMuteAction(),
        TogglePlayIntent: TogglePlayAction(),
        StopPlayIntent: StopPlayAction(),
        SeekIntent: SeekAction(),
        StartDraggingProgressIntent:
            StartDraggingProgressAction(dragBusiness: _dragBusiness),
        DraggingProgressIntent:
            DraggingProgressAction(dragBusiness: _dragBusiness),
        FinishDraggingProgressIntent:
            FinishDraggingProgressAction(dragBusiness: _dragBusiness),
        SetAudioTrackIntent: SetAudioTrackAction(),
        SetSubtitleIntent: SetSubtitleAction(),
        SetSubDelayIntent: SetSubDelayAction(),
        SetSubSizeIntent: SetSubSizeAction(),
        SetSubPosIntent: SetSubPosAction(),
        SetContrastIntent: SetContrastAction(),
      },
      child: shortcuts,
    );
  }
}
