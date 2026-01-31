import 'dart:io';

import 'package:async/async.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/toast.dart';
import 'package:bunga_player/ui/audio_player.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/ui/shortcuts.dart';
import 'package:bunga_player/utils/extensions/comparable.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:path/path.dart' as path_tool;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

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

const _playVolumeKey = 'play_volume';

// Actions

@immutable
class UpdateVolumeIntent extends Intent {
  final Volume? volume;
  final int? offset;
  final bool save;
  const UpdateVolumeIntent(this.volume) : offset = null, save = false;
  const UpdateVolumeIntent.increase(this.offset) : volume = null, save = true;
  const UpdateVolumeIntent.save() : volume = null, offset = null, save = true;
}

class UpdateVolumeAction extends ContextAction<UpdateVolumeIntent> {
  @override
  Future<void> invoke(
    UpdateVolumeIntent intent, [
    BuildContext? context,
  ]) async {
    if (intent.volume != null) {
      getIt<PlayService>().volumeNotifier.value = intent.volume!;
    }
    if (intent.offset != null) {
      final currentVolume = getIt<PlayService>().volumeNotifier.value;
      final newVolume = Volume(
        volume: (currentVolume.volume + intent.offset!).clamp(
          Volume.min,
          Volume.max,
        ),
      );
      getIt<PlayService>().volumeNotifier.value = newVolume;
    }
    if (intent.save) {
      getIt<Preferences>().set(
        _playVolumeKey,
        getIt<PlayService>().volumeNotifier.value.volume,
      );
    }
  }
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
    final play = getIt<PlayService>();
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
    final track = getIt<PlayService>().setSubtitleTrack(intent.trackId);

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
    final positionStr = getIt<PlayService>().positionNotifier.value.toString();
    final positionStamp = positionStr
        .substring(0, positionStr.length - 4)
        .replaceAll(RegExp(r'[:|.]'), '_');
    final videoFileName = playPayloadNotifier.value!.record.title;
    final videoName = path_tool.basenameWithoutExtension(videoFileName);
    final fileName = '${videoName}_$positionStamp.jpg';

    final data = await getIt<PlayService>().screenshot();
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
  final bool forgetSavedPosition;
  const ToggleIntent({this.forgetSavedPosition = false});
}

class ToggleAction extends ContextAction<ToggleIntent> {
  final RestartableTimer saveWatchProgressTimer;

  ToggleAction({required this.saveWatchProgressTimer});

  @override
  void invoke(ToggleIntent intent, [BuildContext? context]) {
    // TODO: change to add listener
    final service = getIt<PlayService>();
    service.toggle();

    // Deal with progress saving business
    if (service.playStatusNotifier.value.isPlaying) {
      saveWatchProgressTimer.reset();
    } else {
      saveWatchProgressTimer.cancel();
    }
  }

  @override
  bool isEnabled(ToggleIntent intent, [BuildContext? context]) {
    if (context == null) return false;

    final isBusy = context.read<BusyStateNotifier>().isBusy;
    return !isBusy;
  }
}

@immutable
class SeekIntent extends Intent {
  const SeekIntent(this.value) : isIncrease = false;
  const SeekIntent.increase(this.value) : isIncrease = true;
  final Duration value;
  final bool isIncrease;

  Duration applyOn(Duration currentPosition, Duration duration) {
    final position = isIncrease ? currentPosition + value : value;
    return position.clamp(Duration.zero, duration);
  }
}

class SeekAction extends ContextAction<SeekIntent> {
  @override
  void invoke(SeekIntent intent, [BuildContext? context]) {
    final service = getIt<PlayService>();

    final position = service.positionNotifier.value;
    final duration = service.durationNotifier.value;
    service.seek(intent.applyOn(position, duration));
  }

  @override
  bool isEnabled(SeekIntent intent, [BuildContext? context]) {
    return getIt<PlayService>().playStatusNotifier.value != PlayStatus.stop;
  }
}

class PlayBusiness extends SingleChildStatefulWidget {
  const PlayBusiness({super.key, super.child});

  @override
  State<PlayBusiness> createState() => _PlayBusinessState();
}

class _PlayBusinessState extends SingleChildState<PlayBusiness> {
  // Progress indicator
  late final _isVideoBufferingNotifier =
      getIt<PlayService>().isBufferingNotifier;
  void _updateBusyState() {
    final notifier = context.read<BusyStateNotifier>();
    _isVideoBufferingNotifier.value
        ? notifier.add('video buffering')
        : notifier.remove('video buffering');
  }

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
  // final _savedPositionNotifier = SavedPositionNotifier(); // For saved postion toast

  @override
  void initState() {
    super.initState();

    _isVideoBufferingNotifier.addListener(_updateBusyState);

    // History
    _history = context.read<History>();

    // Load init volume
    getIt<PlayService>().volumeNotifier.value = Volume(
      volume: getIt<Preferences>().get(_playVolumeKey) ?? Volume.max,
    );
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final shortcuts = child!.applyShortcuts({
      ShortcutKey.volumeUp: UpdateVolumeIntent.increase(10),
      ShortcutKey.volumeDown: UpdateVolumeIntent.increase(-10),
      ShortcutKey.forward5Sec: SeekIntent.increase(Duration(seconds: 5)),
      ShortcutKey.backward5Sec: SeekIntent.increase(Duration(seconds: -5)),
      ShortcutKey.togglePlay: ToggleIntent(),
      ShortcutKey.screenshot: ScreenshotIntent(),
    });

    final actions = shortcuts.actions(
      actions: {
        UpdateVolumeIntent: UpdateVolumeAction(),
        OpenVideoIntent: OpenVideoAction(
          dirInfoNotifier: _dirInfoNotifier,
          payloadNotifer: _playPayloadNotifier,
        ),
        ToggleIntent: ToggleAction(
          saveWatchProgressTimer: _saveWatchProgressTimer,
        ),
        SeekIntent: SeekAction(),
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

    _isVideoBufferingNotifier.removeListener(_updateBusyState);

    _history.save();
    _saveWatchProgressTimer.cancel();
    // _savedPositionNotifier.dispose();

    super.dispose();
  }

  void _updateProgress() {
    final currentRecord = _playPayloadNotifier.value?.record;
    if (currentRecord == null) return;

    final play = getIt<PlayService>();

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
