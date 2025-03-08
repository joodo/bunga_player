import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/play_sync/actions.dart';
import 'package:bunga_player/play/models/track.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/extensions/comparable.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'models/history.dart';
import 'models/play_payload.dart';
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
  Future<void> invoke(SetVolumeIntent intent, [BuildContext? context]) async {
    var volume = intent.volume;
    if (intent.offset) {
      volume += context!.read<PlayVolume>().value.volume;
      context
          .read<JustAdjustedByShortHand>()
          .markWithAction(ShortHandAction.volume);
    }
  }
}

class SetMuteIntent extends Intent {
  final bool mute;

  const SetMuteIntent(this.mute);
}

class SetMuteAction extends Action<SetMuteIntent> {
  @override
  Future<void> invoke(SetMuteIntent intent) async {}
}

class TogglePlayIntent extends Intent {
  const TogglePlayIntent();
}

class TogglePlayAction extends ContextAction<TogglePlayIntent> {
  @override
  Future<void> invoke(TogglePlayIntent intent, [BuildContext? context]) async {
    final read = context!.read;

    /* TODO: onprogress
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
*/
    getIt<PlayService>().toggle();
  }

  @override
  bool isEnabled(TogglePlayIntent intent, [BuildContext? context]) {
    final read = context!.read;
    final isStopped =
        getIt<PlayService>().playStatusNotifier.value == PlayStatus.stop;
    final isToggledByRemote = read<JustToggleByRemote>().value;
    return !isStopped && !isToggledByRemote;
  }
}

class StopPlayIntent extends Intent {
  const StopPlayIntent();
}

class StopPlayAction extends ContextAction<StopPlayIntent> {
  @override
  Future<void> invoke(StopPlayIntent intent, [BuildContext? context]) async {
    final read = context!.read;
    read<WindowTitle>().reset();
    //read<PlaySavedPosition>().value = null;

    getIt<PlayService>().stop();
  }
}

class OpenVideoIntent extends Intent {
  final PlayPayload payload;
  final int sourceIndex;

  const OpenVideoIntent({
    required this.payload,
    this.sourceIndex = 0,
  });
}

class OpenVideoAction extends ContextAction<OpenVideoIntent> {
  OpenVideoAction();

  @override
  Future<void> invoke(OpenVideoIntent intent, [BuildContext? context]) async {
    final read = context!.read;

    final savedPositionNotifer = read<PlaySavedPosition>();
    final videoSessions = read<PlayVideoSessions>();

    final videoPlayer = getIt<PlayService>();
    await videoPlayer.open(intent.payload);

    /* TODO: onprogress
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
      */

    if (context.mounted) {
      read<WindowTitle>().value = intent.payload.record.title;
    }
  }

  @override
  bool isEnabled(OpenVideoIntent intent, [BuildContext? context]) {
    return context != null;
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

      final videoPlayer = getIt<PlayService>();
      final videoSessions = read<PlayVideoSessions>();

      await currentEntry.fetch(read);
      /* TODO: onprogress
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
      */

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
  Future<void>? invoke(SeekIntent intent, [BuildContext? context]) {}

  @override
  bool isEnabled(SeekIntent intent, [BuildContext? context]) {
    return getIt<PlayService>().playStatusNotifier.value != PlayStatus.stop;
  }
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
    getIt<PlayService>().pause();

    final position = read<PlayPosition>();
    position.value = intent.position;
    getIt<PlayService>().seek(intent.position);
  }

  @override
  bool isEnabled(StartDraggingProgressIntent intent, [BuildContext? context]) {
    return getIt<PlayService>().playStatusNotifier.value != PlayStatus.stop;
  }
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
    getIt<PlayService>().seek(intent.position);
  }

  @override
  bool isEnabled(DraggingProgressIntent intent, [BuildContext? context]) {
    final isStopped =
        getIt<PlayService>().playStatusNotifier.value == PlayStatus.stop;
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

    /* TODO: onprogress
    Actions.maybeInvoke(
      context,
      SendPlayingStatusIntent(
        dragBusiness.isPlayingBeforeDraggingSlider
            ? PlayStatusType.play
            : PlayStatusType.pause,
        intent.position,
      ),
    );
    */

    final position = read<PlayPosition>();
    position.value = intent.position;

    if (dragBusiness.isPlayingBeforeDraggingSlider) {
      getIt<PlayService>().play();
    }

    dragBusiness.isDragging = false;
  }

  @override
  bool isEnabled(FinishDraggingProgressIntent intent, [BuildContext? context]) {
    final isStopped =
        getIt<PlayService>().playStatusNotifier.value == PlayStatus.stop;
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
  Future<void> invoke(SetAudioTrackIntent intent) async {}
}

class SetSubtitleIntent extends Intent {
  final String? id;
  const SetSubtitleIntent(this.id);
}

class SetSubtitleAction extends Action<SetSubtitleIntent> {
  @override
  Future<void> invoke(SetSubtitleIntent intent) async {
    //return getIt<Player>().setSubtitleTrackID(intent.id!);
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
      final track = await getIt<PlayService>().loadSubtitleTrack(intent.path!);
      currentSession.subtitleUri = track.path!;
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
  Future<void> invoke(SetSubDelayIntent intent) async {}
}

class SetSubSizeIntent extends Intent {
  final int? size;

  const SetSubSizeIntent([this.size]);
}

class SetSubSizeAction extends Action<SetSubSizeIntent> {
  @override
  Future<void> invoke(SetSubSizeIntent intent) async {}
}

class SetSubPosIntent extends Intent {
  final int? pos;

  const SetSubPosIntent([this.pos]);
}

class SetSubPosAction extends Action<SetSubPosIntent> {
  @override
  Future<void> invoke(SetSubPosIntent intent) async {}
}

class SetContrastIntent extends Intent {
  final int? contrast;
  const SetContrastIntent([this.contrast]);
}

class SetContrastAction extends Action<SetContrastIntent> {
  @override
  Future<void> invoke(SetContrastIntent intent) async {}
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

    final data = await getIt<PlayService>().screenshot();
    assert(data != null);

    final documentDir = await getApplicationDocumentsDirectory();
    final picturePath = '${documentDir.parent.path}/Pictures/Bunga';
    final pictureDir = await Directory(picturePath).create(recursive: true);

    final file = File('${pictureDir.path}/$fileName');
    await file.writeAsBytes(data!);

    getIt<Toast>().show('已截图 $fileName');
    AudioPlayer().play(
      AssetSource('sounds/screenshot.mp3'),
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
  late final _videoEntryNotifer = context.read<PlayVideoEntry>();

  // History
  late final History _history;

  @override
  void initState() {
    super.initState();

    final player = getIt<PlayService>();
    final read = context.read;

    _playRate.addListener(_applyRate);

    _preventAudioDucking();
    _videoEntryNotifer.addListener(_requestSession);

    _streamSubscriptions.addAll(
      <(Stream, ValueNotifier)>[
        (player.videoEntryStream, read<PlayVideoEntry>()),
        (player.sourceIndexStream, read<PlaySourceIndex>()),
      ].map((e) => _bindStreamToValueNotifier(e.$1, e.$2)),
    );

    // History
    _history = History.load();
  }

  @override
  void dispose() async {
    _playRate.removeListener(_applyRate);
    _videoEntryNotifer.removeListener(_requestSession);
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      await subscription.cancel();
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        Provider.value(value: _history),
        // TODO::
        ValueListenableProvider.value(
          value: getIt<PlayService>().playStatusNotifier,
        ),
      ],
      child: child!.actions(actions: {
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
      }),
    );
  }

  StreamSubscription _bindStreamToValueNotifier<T>(
    Stream<T> stream,
    ValueNotifier<T> notifier,
  ) {
    return stream.listen((value) => notifier.value = value);
  }

  void _applyRate() {
    getIt<PlayService>().setRate(_playRate.value);
  }

  void _preventAudioDucking() async {
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isWindows) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  void _requestSession() async {
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isWindows) return;

    final session = await AudioSession.instance;
    if (_videoEntryNotifer.value != null) {
      bool success = await session.setActive(true);
      if (!success) {
        logger.w("Failed to activate audio session");
      }
    } else {
      await session.setActive(false);
    }
  }
}
