import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/play_sync/actions.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/extensions/comparable.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'models/video_entries/video_entry.dart';
import 'service/service.dart';
import 'providers.dart';

class SetVolumeIntent extends Intent {
  const SetVolumeIntent(this.volume) : offset = false;
  const SetVolumeIntent.increase(this.volume) : offset = true;
  final int volume;
  final bool offset;
}

class SetVolumeAction extends ContextAction<SetVolumeIntent> {
  @override
  Future<void> invoke(SetVolumeIntent intent, [BuildContext? context]) {
    var volume = intent.volume;
    if (intent.offset) {
      volume += context!.read<PlayVolume>().value.volume;
      context
          .read<JustAdjustedByShortHand>()
          .markWithAction(ShortHandAction.volume);
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

    // Send status
    final isPlaying = read<PlayStatus>().isPlaying;
    final position = read<PlayPosition>().value;
    Actions.maybeInvoke(
      context,
      SendPlayingStatusIntent(
        !isPlaying ? PlayStatusType.play : PlayStatusType.pause,
        position,
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

class StopPlayIntent extends Intent {
  const StopPlayIntent();
}

class StopPlayAction extends ContextAction<StopPlayIntent> {
  @override
  Future<void> invoke(StopPlayIntent intent, [BuildContext? context]) {
    final read = context!.read;
    read<WindowTitle>().reset();
    read<PlaySavedPosition>().value = null;

    return getIt<Player>().stop();
  }
}

class OpenVideoIntent extends Intent {
  final VideoEntry videoEntry;
  final int sourceIndex;

  const OpenVideoIntent({
    required this.videoEntry,
    this.sourceIndex = 0,
  });
}

class OpenVideoAction extends ContextAction<OpenVideoIntent> {
  OpenVideoAction();

  @override
  Future<void> invoke(OpenVideoIntent intent, [BuildContext? context]) async {
    assert(context != null);
    final read = context!.read;

    final actionLeaf = read<ActionsLeaf>();
    actionLeaf.invoke(const StopPlayIntent());

    final savedPositionNotifer = read<PlaySavedPosition>();
    final videoSessions = read<PlayVideoSessions>();

    final cat = read<CatIndicator>();
    await cat.run(() async {
      cat.title = '正在鬼鬼祟祟';

      final videoPlayer = getIt<Player>();

      await intent.videoEntry.fetch(read);

      videoPlayer.open(intent.videoEntry, intent.sourceIndex).then(
        (_) async {
          final progress = videoSessions.current?.progress;
          if (progress != null) {
            final position = Duration(milliseconds: progress.position);
            videoPlayer.seek(position);
            savedPositionNotifer.value = position;
          }

          final subtitleUri = videoSessions.current?.subtitleUri;
          if (subtitleUri != null) {
            final track = await videoPlayer.loadSubtitleTrack(subtitleUri);
            videoPlayer.setSubtitleTrackID(track.id);
          }
        },
      );

      if (context.mounted) {
        read<WindowTitle>().value = intent.videoEntry.title;
      }

      cat.title = null;
    });
  }
}

class ReloadIntent extends Intent {
  const ReloadIntent();
}

class ReloadAction extends ContextAction<ReloadIntent> {
  @override
  Future<void> invoke(ReloadIntent intent, [BuildContext? context]) async {
    final read = context!.read;

    final currentEntry = read<PlayVideoEntry>().value!;
    final currentIndex = read<PlaySourceIndex>().value!;
    final currentPosition = read<PlayPosition>().value;

    Actions.maybeInvoke(
      context,
      SendPlayingStatusIntent(
        PlayStatusType.pause,
        currentPosition,
      ),
    );

    final cat = read<CatIndicator>();
    await cat.run(() async {
      cat.title = '正在鬼鬼祟祟';

      final videoPlayer = getIt<Player>();
      final videoSessions = read<PlayVideoSessions>();

      await currentEntry.fetch(read);
      videoPlayer.open(currentEntry, currentIndex).then(
        (_) async {
          videoPlayer.seek(currentPosition);

          final subtitleUri = videoSessions.current?.subtitleUri;
          if (subtitleUri != null) {
            final track = await videoPlayer.loadSubtitleTrack(subtitleUri);
            videoPlayer.setSubtitleTrackID(track.id);
          }
        },
      );

      cat.title = null;
    });
  }

  @override
  bool isEnabled(ReloadIntent intent, [BuildContext? context]) {
    if (context == null) return false;

    final entry = context.read<PlayVideoEntry>().value;
    if (entry == null) return false;

    return true;
  }
}

class SeekIntent extends Intent {
  const SeekIntent(this.duration) : isIncrease = false;
  const SeekIntent.increase(this.duration) : isIncrease = true;
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
        newPos,
      ),
    ) as Future<void>?;
  }

  @override
  bool isEnabled(SeekIntent intent, [BuildContext? context]) =>
      context!.read<PlayStatus>().value != PlayStatusType.stop;
}

class DragBusiness {
  bool isPlayingBeforeDraggingSlider = false;
  bool isDragging = false;
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
    dragBusiness.isDragging = true;

    final read = context!.read;

    dragBusiness.isPlayingBeforeDraggingSlider = read<PlayStatus>().isPlaying;
    getIt<Player>().pause();

    final position = read<PlayPosition>();
    position.value = intent.position;
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
    position.value = intent.position;
    getIt<Player>().seek(intent.position);
  }

  @override
  bool isEnabled(DraggingProgressIntent intent, [BuildContext? context]) {
    final isStopped = context!.read<PlayStatus>().value == PlayStatusType.stop;
    final isDragging = dragBusiness.isDragging;
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
        intent.position,
      ),
    );

    final position = read<PlayPosition>();
    position.value = intent.position;
    await getIt<Player>().seek(intent.position);

    if (dragBusiness.isPlayingBeforeDraggingSlider) {
      await getIt<Player>().play();
    }

    dragBusiness.isDragging = false;
  }

  @override
  bool isEnabled(FinishDraggingProgressIntent intent, [BuildContext? context]) {
    final isStopped = context!.read<PlayStatus>().value == PlayStatusType.stop;
    final isDragging = dragBusiness.isDragging;
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
  const SetSubtitleIntent(this.id);
}

class SetSubtitleAction extends Action<SetSubtitleIntent> {
  @override
  Future<void> invoke(SetSubtitleIntent intent) async {
    return getIt<Player>().setSubtitleTrackID(intent.id!);
  }
}

class LoadLocalSubtitleIntent extends Intent {
  final String? path;
  const LoadLocalSubtitleIntent(this.path);
}

class LoadLocalSubtitleAction extends ContextAction<LoadLocalSubtitleIntent> {
  @override
  Future<SubtitleTrack?> invoke(
    LoadLocalSubtitleIntent intent, [
    BuildContext? context,
  ]) async {
    try {
      final currentSession =
          context!.read<PlayVideoSessions>().currentOrCreate();
      final track = await getIt<Player>().loadSubtitleTrack(intent.path!);
      currentSession.subtitleUri = track.uri!;
      return track;
    } catch (e) {
      getIt<Toast>().show('字幕加载失败');
      return null;
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

class ScreenshotIntent extends Intent {
  const ScreenshotIntent();
}

class ScreenshotAction extends ContextAction<ScreenshotIntent> {
  @override
  Future<File> invoke(ScreenshotIntent intent, [BuildContext? context]) async {
    final positionStr = context!.read<PlayPosition>().value.toString();
    final positionStamp = positionStr
        .substring(0, positionStr.length - 4)
        .replaceAll(RegExp(r'[:|.]'), '_');
    final videoFileName = context.read<PlayVideoEntry>().value!.title;
    final videoName = path.basenameWithoutExtension(videoFileName);
    final fileName = '${videoName}_$positionStamp.jpg';

    final data = await getIt<Player>().screenshot();
    assert(data != null);

    final documentDir = await getApplicationDocumentsDirectory();
    final picturePath = '${documentDir.parent.path}/Pictures/Bunga';
    final pictureDir = await Directory(picturePath).create(recursive: true);

    final file = File('${pictureDir.path}/$fileName');
    await file.writeAsBytes(data!);

    getIt<Toast>().show('已截图 $fileName');
    AudioPlayer().play(
      AssetSource('sounds/screenshot.wav'),
      mode: PlayerMode.lowLatency,
    );

    return file;
  }

  @override
  bool isEnabled(ScreenshotIntent intent, [BuildContext? context]) {
    return context?.read<PlayVideoEntry>().value != null;
  }
}

class PlayActions extends SingleChildStatefulWidget {
  const PlayActions({super.key, super.child});

  @override
  State<PlayActions> createState() => _PlayActionsState();
}

class _PlayActionsState extends SingleChildState<PlayActions> {
  final _dragBusiness = DragBusiness();

  final _streamSubscriptions = <StreamSubscription>[];

  late final _playRate = context.read<PlayRate>();

  @override
  void initState() {
    super.initState();

    final player = getIt<Player>();
    final read = context.read;

    // init volume
    player.setVolume(read<PlayVolume>().value.volume);

    _playRate.addListener(_applyRate);

    _streamSubscriptions.addAll(
      <(Stream, ValueNotifier)>[
        (player.durationStream, read<PlayDuration>()),
        (player.bufferStream, read<PlayBuffer>()),
        (player.isBufferingStream, read<PlayIsBuffering>()),
        (player.audioTracksStream, read<PlayAudioTracks>()),
        (player.currentAudioTrackID, read<PlayAudioTrackID>()),
        (player.subtitleTracksStream, read<PlaySubtitleTracks>()),
        (player.currentSubtitleTrackID, read<PlaySubtitleTrackID>()),
        (player.statusStream, read<PlayStatus>()),
        (player.volumeStream, read<PlayVolume>()),
        (player.contrastStream, read<PlayContrast>()),
        (player.subDelayStream, read<PlaySubDelay>()),
        (player.subSizeStream, read<PlaySubSize>()),
        (player.subPosStream, read<PlaySubPos>()),
        (player.videoEntryStream, read<PlayVideoEntry>()),
        (player.sourceIndexStream, read<PlaySourceIndex>()),
      ].map((e) => _bindStreamToValueNotifier(e.$1, e.$2)),
    );

    _streamSubscriptions.add(player.positionStream.listen((position) {
      if (!_dragBusiness.isDragging) read<PlayPosition>().value = position;
    }));
  }

  @override
  void dispose() async {
    _playRate.removeListener(_applyRate);
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      await subscription.cancel();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      actions: <Type, Action<Intent>>{
        SetVolumeIntent: SetVolumeAction(),
        SetMuteIntent: SetMuteAction(),
        TogglePlayIntent: TogglePlayAction(),
        StopPlayIntent: StopPlayAction(),
        OpenVideoIntent: OpenVideoAction(),
        ReloadIntent: ReloadAction(),
        SeekIntent: SeekAction(),
        StartDraggingProgressIntent:
            StartDraggingProgressAction(dragBusiness: _dragBusiness),
        DraggingProgressIntent:
            DraggingProgressAction(dragBusiness: _dragBusiness),
        FinishDraggingProgressIntent:
            FinishDraggingProgressAction(dragBusiness: _dragBusiness),
        SetAudioTrackIntent: SetAudioTrackAction(),
        SetSubtitleIntent: SetSubtitleAction(),
        LoadLocalSubtitleIntent: LoadLocalSubtitleAction(),
        SetSubDelayIntent: SetSubDelayAction(),
        SetSubSizeIntent: SetSubSizeAction(),
        SetSubPosIntent: SetSubPosAction(),
        SetContrastIntent: SetContrastAction(),
        ScreenshotIntent: ScreenshotAction(),
      },
      child: child!,
    );
  }

  StreamSubscription _bindStreamToValueNotifier<T>(
    Stream<T> stream,
    ValueNotifier<T> notifier,
  ) {
    return stream.listen((value) => notifier.value = value);
  }

  void _applyRate() {
    getIt<Player>().setRate(_playRate.value);
  }
}
