import 'package:async/async.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/play/providers.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/utils/extensions/comparable.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'models/history.dart';
import 'models/play_payload.dart';
import 'models/video_record.dart';
import 'payload_parser.dart';
import 'service/service.dart';

// Data types

@immutable
class BusyCount {
  final int _count;
  const BusyCount(this._count);

  bool get isBusy => _count > 0;
  BusyCount get increase => BusyCount(_count + 1);
  BusyCount get decrease => BusyCount(_count - 1);
}

class SavedPositionNotifier extends ValueNotifier<Duration?> {
  SavedPositionNotifier() : super(null);
}

// Actions

@immutable
class OpenVideoIntent extends Intent {
  final Uri? url;
  final VideoRecord? record;
  final PlayPayload? payload;

  const OpenVideoIntent.url(Uri this.url)
      : payload = null,
        record = null;
  const OpenVideoIntent.record(VideoRecord this.record)
      : url = null,
        payload = null;
  const OpenVideoIntent.payload(PlayPayload this.payload)
      : url = null,
        record = null;
}

class OpenVideoAction extends ContextAction<OpenVideoIntent> {
  final ValueNotifier<PlayPayload?> payloadNotifer;
  final ValueNotifier<BusyCount> busyCountNotifier;
  final ValueNotifier<DirInfo?> dirInfoNotifier;
  final SavedPositionNotifier savedPositionNotifier;

  OpenVideoAction({
    required this.payloadNotifer,
    required this.busyCountNotifier,
    required this.dirInfoNotifier,
    required this.savedPositionNotifier,
  });

  @override
  Future<PlayPayload> invoke(OpenVideoIntent intent,
      [BuildContext? context]) async {
    assert(context != null);

    final parser = PlayPayloadParser(context!);
    final play = getIt<PlayService>();
    late final PlayPayload payload;

    // Open video
    try {
      busyCountNotifier.value = busyCountNotifier.value.increase;

      payload = intent.payload ??
          await parser.parse(
            url: intent.url,
            record: intent.record,
          );

      await play.open(payload);

      if (!context.mounted) throw StateError('Context unmounted.');
      context.read<WindowTitle>().value = payload.record.title;

      payloadNotifer.value = payload;
    } catch (e) {
      getIt<Toast>().show('载入视频失败');
      rethrow;
    } finally {
      busyCountNotifier.value = busyCountNotifier.value.decrease;
    }

    // Load history
    if (!context.mounted) throw StateError('Context unmounted.');
    final session = context.read<History>().value[payload.record.id];

    final savedPostion = session?.progress?.position;
    if (savedPostion != null) {
      play.seek(savedPostion);
      savedPositionNotifier.value = savedPostion;
    } else {
      savedPositionNotifier.value = null;
    }

    final subPath = session?.subtitlePath;
    if (subPath != null) {
      final track = await play.loadSubtitleTrack(subPath);
      play.setSubtitleTrack(track.id);
    }

    // Load dir info
    parser.dirInfo(payload.record).then((info) {
      dirInfoNotifier.value = info;
    });

    return payload;
  }
}

@immutable
class StopPlayingIntent extends Intent {
  const StopPlayingIntent();
}

class StopPlayingAction extends ContextAction<StopPlayingIntent> {
  @override
  void invoke(StopPlayingIntent intent, [BuildContext? context]) async {
    context!.read<WindowTitle>().reset();
    context.read<History>().save();
    getIt<PlayService>().stop();
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
    history.update(videoRecord: record, subtitlePath: externalSubPath);
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
    return PlayPayloadParser(context)
        .dirInfo(currentRecord, refresh: true)
        .then((value) {
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
  final SavedPositionNotifier savedPositionNotifier;

  ToggleAction({
    required this.saveWatchProgressTimer,
    required this.savedPositionNotifier,
  });

  @override
  void invoke(ToggleIntent intent, [BuildContext? context]) {
    final service = getIt<PlayService>();
    service.toggle();

    // Deal with progress saving business
    if (service.playStatusNotifier.value.isPlaying) {
      saveWatchProgressTimer.reset();
    } else {
      saveWatchProgressTimer.cancel();
    }

    if (intent.forgetSavedPosition) {
      // Toggle is invoked by me, not remote, so I can forget saved position.
      savedPositionNotifier.value = null;
    }
  }

  @override
  bool isEnabled(ToggleIntent intent, [BuildContext? context]) {
    if (context == null) return false;

    final isBusy = context.read<BusyCount>().isBusy;
    return !isBusy;
  }
}

@immutable
class SeekIntent extends Intent {
  const SeekIntent(this.duration) : isIncrease = false;
  const SeekIntent.increase(this.duration) : isIncrease = true;
  final Duration duration;
  final bool isIncrease;
}

class SeekAction extends ContextAction<SeekIntent> {
  @override
  void invoke(SeekIntent intent, [BuildContext? context]) {
    final service = getIt<PlayService>();

    final position = service.positionNotifier.value;
    var newPos = intent.duration;
    if (intent.isIncrease) newPos += position;

    newPos = newPos.clamp(Duration.zero, service.durationNotifier.value);
    service.seek(newPos);
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
  final _busyCountNotifer = ValueNotifier(const BusyCount(0));
  late final _isVideoBufferingNotifier = context.read<PlayIsBuffering>();
  void _updateBusyCount() {
    _busyCountNotifer.value = _isVideoBufferingNotifier.value
        ? _busyCountNotifer.value.increase
        : _busyCountNotifer.value.decrease;
  }

  // Play payload
  final _playPayloadNotifier = ValueNotifier<PlayPayload?>(null)
    ..watchInConsole('Play Payload');
  final _dirInfoNotifier = ValueNotifier<DirInfo?>(null);

  // History
  late final _history = context.read<History>();
  late final RestartableTimer _saveWatchProgressTimer = RestartableTimer(
    const Duration(seconds: 3),
    () {
      _updateProgress();
      _saveWatchProgressTimer.reset();
    },
  )..cancel();
  final _savedPositionNotifier =
      SavedPositionNotifier(); // For saved postion toast

  @override
  void initState() {
    super.initState();

    _isVideoBufferingNotifier.addListener(_updateBusyCount);
    _busyCountNotifer.addListener(() {
      final showHUDNotifier = context.read<ShouldShowHUD>();
      if (_busyCountNotifer.value.isBusy) {
        showHUDNotifier.lockUp('busy');
      } else {
        showHUDNotifier.unlock('busy');
      }
    });

    // History
    _history;
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _playPayloadNotifier),
        ChangeNotifierProvider.value(value: _savedPositionNotifier),
        ValueListenableProvider.value(value: _dirInfoNotifier),
        ValueListenableProvider.value(value: _busyCountNotifer),
      ],
      child: child?.actions(actions: {
        OpenVideoIntent: OpenVideoAction(
          busyCountNotifier: _busyCountNotifer,
          dirInfoNotifier: _dirInfoNotifier,
          payloadNotifer: _playPayloadNotifier,
          savedPositionNotifier: _savedPositionNotifier,
        ),
        StopPlayingIntent: StopPlayingAction(),
        ToggleIntent: ToggleAction(
          saveWatchProgressTimer: _saveWatchProgressTimer,
          savedPositionNotifier: _savedPositionNotifier,
        ),
        SeekIntent: SeekAction(),
        SetSubtitleTrackIntent: SetSubtitleTrackAction(),
        RefreshDirIntent: RefreshDirAction(dirInfoNotifier: _dirInfoNotifier),
      }),
    );
  }

  @override
  void dispose() {
    _playPayloadNotifier.dispose();
    _busyCountNotifer.dispose();

    _isVideoBufferingNotifier.removeListener(_updateBusyCount);

    _saveWatchProgressTimer.cancel();
    _savedPositionNotifier.dispose();

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
    _history.update(videoRecord: currentRecord, progress: progress);
  }
}

extension WrapPlayBusiness on Widget {
  Widget playBusiness({Key? key}) => PlayBusiness(key: key, child: this);
}
