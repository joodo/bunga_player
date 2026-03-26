import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:bunga_player/ui/global_business.dart';

import 'providers.dart';
import 'history.dart';
import 'models/history.dart';
import 'models/play_payload.dart';
import 'payload_parser.dart';
import 'service/service.dart';

class PlayBusiness extends SingleChildStatefulWidget {
  const PlayBusiness({
    super.key,
    super.child,
    required this.playPayloadNotifier,
    required this.dirInfoNotifier,
  });

  final ValueNotifier<PlayPayload?> playPayloadNotifier;
  final ValueNotifier<DirInfo?> dirInfoNotifier;

  @override
  State<PlayBusiness> createState() => _PlayBusinessState();
}

class _PlayBusinessState extends SingleChildState<PlayBusiness> {
  // History
  late final History _history;
  late final RestartableTimer _saveWatchProgressTimer = RestartableTimer(
    const Duration(seconds: 5),
    () {
      _updateProgress();
      _saveWatchProgressTimer.reset();
    },
  )..cancel();

  @override
  void initState() {
    super.initState();

    widget.playPayloadNotifier.addListener(_fetchDir);

    if (kIsDesktop) widget.playPayloadNotifier.addListener(_updateWindowTitle);

    // History
    MediaPlayer.i.playStatusNotifier.addListener(_updateHistory);
    _saveWatchProgressTimer;
    _history = context.read<History>();

    MediaPlayer.i.positionNotifier.addListener(_updateExpectedPosition);
  }

  @override
  void dispose() {
    if (kIsDesktop) runAfterBuild(_windowTitleNotifier.reset);

    MediaPlayer.i.playStatusNotifier.removeListener(_updateHistory);
    MediaPlayer.i.positionNotifier.removeListener(_updateExpectedPosition);

    _saveWatchProgressTimer.cancel();

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child!;
  }

  void _updateProgress() {
    final currentRecord = widget.playPayloadNotifier.value?.record;
    if (currentRecord == null) return;

    final progress = WatchProgress(
      position: MediaPlayer.i.positionNotifier.value,
      duration: MediaPlayer.i.durationNotifier.value,
    );
    _history.updateProgress(currentRecord, progress);
  }

  void _updateHistory() {
    if (MediaPlayer.i.playStatusNotifier.value.isPlaying) {
      _saveWatchProgressTimer.reset();
    } else {
      _saveWatchProgressTimer.cancel();
    }
  }

  Future<void> _fetchDir() async {
    final record = widget.playPayloadNotifier.value?.record;
    if (record == null) return;

    final parser = PlayPayloadParser(context);

    final dirInfo = await parser.dirInfo(record);
    widget.dirInfoNotifier.value = dirInfo;
  }

  late final _windowTitleNotifier = context.read<WindowTitleNotifier>();
  void _updateWindowTitle() {
    final title = widget.playPayloadNotifier.value?.record.title;
    if (title == null) {
      _windowTitleNotifier.reset();
    } else {
      _windowTitleNotifier.value = title;
    }
  }

  void _updateExpectedPosition() {
    final player = MediaPlayer.i;
    if (player.duration == Duration.zero) return;
    if (!player.isPlaying) return;

    context.read<ExpectedPosition>().value = player.position;
  }
}

extension WrapPlayBusiness on Widget {
  Widget playBusiness({
    required ValueNotifier<PlayPayload?> playPayloadNotifier,
    required ValueNotifier<DirInfo?> dirInfoNotifier,
  }) => PlayBusiness(
    dirInfoNotifier: dirInfoNotifier,
    playPayloadNotifier: playPayloadNotifier,
    child: this,
  );
}
