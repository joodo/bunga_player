import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:path/path.dart' as path_tool;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/toast.dart';
import 'package:bunga_player/ui/audio_player.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/ui/shortcuts.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:bunga_player/utils/models/volume.dart';

import 'history.dart';
import 'models/history.dart';
import 'models/play_payload.dart';
import 'models/video_record.dart';
import 'payload_parser.dart';
import 'service/service.dart';

// Data types

typedef BCSGHPreset = ({String title, List<int> value});

class PlayEqPresetNotifier extends ValueNotifier<BCSGHPreset?> {
  static final presets = <BCSGHPreset>[
    (title: '默认', value: [0, 0, 0, 0, 0]),
    (title: '鲜艳与生动', value: [5, 20, 65, 10, 0]),
    (title: '电影感', value: [-5, 30, 10, -5, 0]),
    (title: '温暖与复古', value: [10, 15, 10, 5, 5]),
    (title: '凉爽与情绪化', value: [-5, 20, -10, -10, -5]),
    (title: '夜视模式', value: [30, 40, -30, 20, 90]),
    (title: '黑白经典', value: [0, 15, -100, 0, 0]),
    (title: '褐色调', value: [5, 10, -20, 0, 30]),
    (title: '高调', value: [20, -15, 10, 10, 0]),
    (title: '低调', value: [-20, 25, -10, -10, 0]),
    (title: '漂白偏移', value: [0, 30, -50, 0, 0]),
  ];
  PlayEqPresetNotifier() : super(presets.first);
}

class SavedPositionNotifier extends ValueNotifier<Duration?> {
  SavedPositionNotifier() : super(null);
}

// Actions
class UpdateVolumeIntent extends Intent {
  final Volume volume;
  final bool save;
  const UpdateVolumeIntent(this.volume, {this.save = false});
}

class FinishUpdateVolumeIntent extends Intent {
  const FinishUpdateVolumeIntent();
}

class UpdateVolumeForwardIntent extends Intent {
  final double offset;
  const UpdateVolumeForwardIntent(this.offset);
}

@immutable
class OpenVideoIntent extends Intent {
  final Uri? url;
  final VideoRecord? record;
  final PlayPayload? payload;
  final Duration? start;

  const OpenVideoIntent.url(Uri this.url, {this.start})
    : payload = null,
      record = null;
  const OpenVideoIntent.record(VideoRecord this.record, {this.start})
    : url = null,
      payload = null;
  const OpenVideoIntent.payload(PlayPayload this.payload, {this.start})
    : url = null,
      record = null;
}

class OpenVideoAction extends ContextAction<OpenVideoIntent> {
  final ValueNotifier<PlayPayload?> payloadNotifer;
  final ValueNotifier<DirInfo?> dirInfoNotifier;

  OpenVideoAction({
    required this.payloadNotifer,
    required this.dirInfoNotifier,
  });

  @override
  Future<PlayPayload> invoke(
    OpenVideoIntent intent, [
    BuildContext? context,
  ]) async {
    assert(context != null);

    final parser = PlayPayloadParser(context!);
    final busyNotifier = context.read<BusyStateNotifier>();

    try {
      busyNotifier.add('open video');

      final payload =
          intent.payload ??
          await parser.parse(url: intent.url, record: intent.record);

      if (!context.mounted) throw StateError('Context unmounted.');

      // Window title
      context.read<WindowTitleNotifier>().value = payload.record.title;

      // History
      final session = context.read<History>()[payload.record.id];
      final subPath = session?.subtitlePath;

      _loadDir(payload, parser);
      await _loadVideo(
        payload: payload,
        parser: parser,
        subtitlePath: subPath,
        start: intent.start ?? session?.progress?.position,
      );

      payloadNotifer.value = payload;

      return payload;
    } catch (e) {
      getIt<Toast>().show('载入视频失败');
      rethrow;
    } finally {
      busyNotifier.remove('open video');
    }
  }

  Future<void> _loadVideo({
    required PlayPayload payload,
    required PlayPayloadParser parser,
    String? subtitlePath,
    Duration? start,
  }) async {
    final play = getIt<MediaPlayer>();
    await play.open(payload, start);

    // load history
    if (subtitlePath != null) {
      final track = await play.loadSubtitleTrack(subtitlePath);
      play.setSubtitleTrack(track.id);
    }
  }

  Future<void> _loadDir(PlayPayload payload, PlayPayloadParser parser) {
    return parser.dirInfo(payload.record).then((info) {
      dirInfoNotifier.value = info;
    });
  }
}

@immutable
class SetSubtitleTrackIntent extends Intent {
  final String trackId;
  const SetSubtitleTrackIntent(this.trackId);
}

class SetSubtitleTrackAction extends ContextAction<SetSubtitleTrackIntent> {
  @override
  void invoke(SetSubtitleTrackIntent intent, [BuildContext? context]) {
    final track = getIt<MediaPlayer>().setSubtitleTrack(intent.trackId);

    final record = context!.read<PlayPayload>().record;
    final externalSubPath = track.path;
    final history = context.read<History>();
    history.updateSubtitle(record, externalSubPath);
  }
}

@immutable
class ScreenshotIntent extends Intent {
  const ScreenshotIntent();
}

class ScreenshotAction extends ContextAction<ScreenshotIntent> {
  final ValueListenable<PlayPayload?> playPayloadNotifier;

  ScreenshotAction({required this.playPayloadNotifier});

  @override
  Future<File> invoke(ScreenshotIntent intent, [BuildContext? context]) async {
    final positionStr = getIt<MediaPlayer>().positionNotifier.value.toString();
    final positionStamp = positionStr
        .substring(0, positionStr.length - 4)
        .replaceAll(RegExp(r'[:|.]'), '_');
    final videoFileName = playPayloadNotifier.value!.record.title;
    final videoName = path_tool.basenameWithoutExtension(videoFileName);
    final fileName = '${videoName}_$positionStamp.jpg';

    final data = await getIt<MediaPlayer>().screenshot();
    assert(data != null);

    final documentDir = await getApplicationDocumentsDirectory();
    final picturePath = '${documentDir.parent.path}/Pictures/Bunga';
    final pictureDir = await Directory(picturePath).create(recursive: true);

    final file = File('${pictureDir.path}/$fileName');
    await file.writeAsBytes(data!);

    if (context != null && context.mounted) {
      context.read<PlaySyncMessageManager>().show('已截图 $fileName');
      context.read<BungaAudioPlayer>().playSfx('screenshot');
    }
    return file;
  }
}

@immutable
class RefreshDirIntent extends Intent {
  const RefreshDirIntent();
}

class RefreshDirAction extends ContextAction<RefreshDirIntent> {
  final ValueNotifier<DirInfo?> dirInfoNotifier;

  RefreshDirAction({required this.dirInfoNotifier});

  @override
  Future<void> invoke(RefreshDirIntent intent, [BuildContext? context]) {
    final currentRecord = context!.read<PlayPayload>().record;
    return PlayPayloadParser(
      context,
    ).dirInfo(currentRecord, refresh: true).then((value) {
      dirInfoNotifier.value = value;
    });
  }

  @override
  bool isEnabled(RefreshDirIntent intent, [BuildContext? context]) {
    return context != null && context.read<PlayPayload?>() != null;
  }
}

@immutable
class ToggleIntent extends Intent {
  final bool showVisualFeedback;
  const ToggleIntent({this.showVisualFeedback = true});
}

class ToggleAction extends ContextAction<ToggleIntent> {
  final RestartableTimer saveWatchProgressTimer;

  ToggleAction({required this.saveWatchProgressTimer});

  @override
  Future<void> invoke(ToggleIntent intent, [BuildContext? context]) async {
    final service = getIt<MediaPlayer>();
    await service.toggle();

    // Handle progress saving business
    if (service.playStatusNotifier.value.isPlaying) {
      saveWatchProgressTimer.reset();
    } else {
      saveWatchProgressTimer.cancel();
    }

    if (intent.showVisualFeedback) {
      context?.read<PlayToggleVisualSignal?>()?.fire();
    }
  }

  @override
  bool isEnabled(ToggleIntent intent, [BuildContext? context]) {
    return context != null;
  }
}

abstract class SeekIntent extends Intent {
  Duration get position;
  const SeekIntent();
}

class SeekStartIntent extends Intent {
  const SeekStartIntent();
}

class SeekEndIntent extends Intent {
  @override
  const SeekEndIntent();
}

class SeekForwardIntent extends SeekIntent {
  final Duration delta;
  const SeekForwardIntent(this.delta);
  @override
  Duration get position {
    final player = getIt<MediaPlayer>();
    final current = player.positionNotifier.value;
    return current + delta;
  }
}

class SeekAction extends ContextAction<SeekIntent> {
  @override
  void invoke(SeekIntent intent, [BuildContext? context]) {
    final service = getIt<MediaPlayer>();
    service.seek(intent.position);
  }

  @override
  bool isEnabled(SeekIntent intent, [BuildContext? context]) {
    return getIt<MediaPlayer>().playStatusNotifier.value != PlayStatus.stop;
  }
}

class PlayBusiness extends SingleChildStatefulWidget {
  const PlayBusiness({super.key, super.child});

  @override
  State<PlayBusiness> createState() => _PlayBusinessState();
}

class _PlayBusinessState extends SingleChildState<PlayBusiness> {
  // Play payload
  final _playPayloadNotifier = ValueNotifier<PlayPayload?>(null)
    ..watchInConsole('Play Payload');
  final _dirInfoNotifier = ValueNotifier<DirInfo?>(null);

  // History
  late final History _history;
  late final RestartableTimer _saveWatchProgressTimer = RestartableTimer(
    const Duration(seconds: 7),
    () {
      _updateProgress();
      _saveWatchProgressTimer.reset();
    },
  )..cancel();

  @override
  void initState() {
    super.initState();

    // History
    _history = context.read<History>();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final shortcuts = child!.applyShortcuts({
      ShortcutKey.volumeUp: UpdateVolumeForwardIntent(0.1),
      ShortcutKey.volumeDown: UpdateVolumeForwardIntent(-0.1),
      ShortcutKey.forward5Sec: SeekForwardIntent(Duration(seconds: 5)),
      ShortcutKey.backward5Sec: SeekForwardIntent(Duration(seconds: -5)),
      ShortcutKey.togglePlay: ToggleIntent(),
      ShortcutKey.screenshot: ScreenshotIntent(),
    });

    final actions = shortcuts.actions(
      actions: {
        UpdateVolumeIntent: CallbackAction<UpdateVolumeIntent>(
          onInvoke: (intent) {
            final notifier = context.read<MediaVolumeNotifier>();
            notifier.value = intent.volume;
            if (intent.save) notifier.saveToPref();
            return null;
          },
        ),
        FinishUpdateVolumeIntent: CallbackAction<FinishUpdateVolumeIntent>(
          onInvoke: (intent) {
            final notifier = context.read<MediaVolumeNotifier>();
            notifier.saveToPref();
            return null;
          },
        ),
        UpdateVolumeForwardIntent: CallbackAction<UpdateVolumeForwardIntent>(
          onInvoke: (intent) {
            final notifier = context.read<MediaVolumeNotifier>();
            notifier.forward(intent.offset);
            notifier.saveToPref();

            context.read<AdjustIndicatorEvent>().fire(.volume);

            return null;
          },
        ),
        OpenVideoIntent: OpenVideoAction(
          dirInfoNotifier: _dirInfoNotifier,
          payloadNotifer: _playPayloadNotifier,
        ),
        ToggleIntent: ToggleAction(
          saveWatchProgressTimer: _saveWatchProgressTimer,
        ),
        SeekForwardIntent: SeekAction(),
        SetSubtitleTrackIntent: SetSubtitleTrackAction(),
        ScreenshotIntent: ScreenshotAction(
          playPayloadNotifier: _playPayloadNotifier,
        ),
        RefreshDirIntent: RefreshDirAction(dirInfoNotifier: _dirInfoNotifier),
      },
    );

    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _playPayloadNotifier),
        ValueListenableProvider.value(value: _dirInfoNotifier),
        ChangeNotifierProvider(create: (context) => PlayEqPresetNotifier()),
      ],
      child: actions,
    );
  }

  @override
  void dispose() {
    _playPayloadNotifier.dispose();

    _history.save();
    _saveWatchProgressTimer.cancel();

    super.dispose();
  }

  void _updateProgress() {
    final currentRecord = _playPayloadNotifier.value?.record;
    if (currentRecord == null) return;

    final play = getIt<MediaPlayer>();

    final progress = WatchProgress(
      position: play.positionNotifier.value,
      duration: play.durationNotifier.value,
    );
    _history.updateProgress(currentRecord, progress);
  }
}

extension WrapPlayBusiness on Widget {
  Widget playBusiness({Key? key}) => PlayBusiness(key: key, child: this);
}
