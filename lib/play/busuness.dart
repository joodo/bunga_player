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
    final videoPlayer = getIt<PlayService>();
    late final PlayPayload payload;

    // Open video
    try {
      busyCountNotifier.value = busyCountNotifier.value.increase;

      payload = intent.payload ??
          await parser.parse(
            url: intent.url,
            record: intent.record,
          );

      await videoPlayer.open(payload);

      if (!context.mounted) throw StateError('Context unmounted.');
      context.read<WindowTitle>().value = payload.record.title;

      payloadNotifer.value = payload;
    } catch (e) {
      getIt<Toast>().show('载入视频失败');
      rethrow;
    } finally {
      busyCountNotifier.value = busyCountNotifier.value.decrease;
    }

    // Load saved position
    if (!context.mounted) throw StateError('Context unmounted.');
    final history = context.read<History>();
    final savedPostion = history.value[payload.record.id]?.progress.position;
    if (savedPostion != null) {
      videoPlayer.seek(savedPostion);
      savedPositionNotifier.value = savedPostion;
    } else {
      savedPositionNotifier.value = null;
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
  void invoke(StopPlayingIntent intent, [BuildContext? context]) {
    context!.read<WindowTitle>().reset();
    getIt<PlayService>().stop();
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
      final currentRecord = _playPayloadNotifier.value?.record;
      if (currentRecord == null) return;

      final player = getIt<PlayService>();

      final historyValue = _history.value;

      final progress = WatchProgress(
        position: player.positionNotifier.value,
        duration: player.durationNotifier.value,
      );
      if (historyValue.containsKey(currentRecord.id)) {
        historyValue[currentRecord.id] =
            historyValue[currentRecord.id]!.copyWith(
          updatedAt: DateTime.now(),
          progress: progress,
        );
      } else {
        historyValue[currentRecord.id] = VideoSession(
          videoRecord: currentRecord,
          updatedAt: DateTime.now(),
          progress: progress,
        );
      }
      _saveWatchProgressTimer.reset();
    },
  )..cancel();
  final _savedPositionNotifier =
      SavedPositionNotifier(); // For saved postion toast

  @override
  void initState() {
    super.initState();

    _isVideoBufferingNotifier.addListener(_updateBusyCount);

    // Init late variables
    _history;
  }

  @override
  void dispose() {
    _playPayloadNotifier.dispose();
    _busyCountNotifer.dispose();

    _isVideoBufferingNotifier.removeListener(_updateBusyCount);

    _saveWatchProgressTimer.cancel();
    _history.save();
    _savedPositionNotifier.dispose();

    super.dispose();
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
        RefreshDirIntent: RefreshDirAction(dirInfoNotifier: _dirInfoNotifier),
      }),
    );
  }
}

extension WrapPlayBusiness on Widget {
  Widget playBusiness({Key? key}) => PlayBusiness(key: key, child: this);
}
