import 'package:async/async.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/history.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/utils/extensions/comparable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'panel/panel.dart';

class ShowPanelIntent extends Intent {
  final Panel Function(BuildContext context) builder;
  const ShowPanelIntent({required this.builder});
}

class ShowPanelAction extends ContextAction<ShowPanelIntent> {
  final ValueNotifier<Panel?> widgetNotifier;
  ShowPanelAction({required this.widgetNotifier});

  @override
  Future<void> invoke(ShowPanelIntent intent, [BuildContext? context]) async {
    widgetNotifier.value = intent.builder(context!);
  }
}

class ClosePanelIntent extends Intent {}

class ClosePanelAction extends ContextAction<ClosePanelIntent> {
  final ValueNotifier<Widget?> widgetNotifier;
  ClosePanelAction({required this.widgetNotifier});

  @override
  Future<void> invoke(ClosePanelIntent intent, [BuildContext? context]) async {
    widgetNotifier.value = null;
  }
}

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

class RefreshDirIntent extends Intent {}

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

class ToggleIntent extends Intent {}

class ToggleAction extends Action<ToggleIntent> {
  final RestartableTimer saveWatchProgressTimer;
  final SavedPositionNotifier savedPositionNotifier;

  ToggleAction({
    required this.saveWatchProgressTimer,
    required this.savedPositionNotifier,
  });

  @override
  void invoke(ToggleIntent intent) {
    final service = getIt<PlayService>();
    if (service.playStatusNotifier.value.isPlaying) {
      saveWatchProgressTimer.cancel();
    } else {
      saveWatchProgressTimer.reset();
      savedPositionNotifier.value = null;
    }

    getIt<PlayService>().toggle();
  }

  @override
  bool isEnabled(ToggleIntent intent) {
    return getIt<PlayService>().playStatusNotifier.value != PlayStatus.stop;
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
  void invoke(SeekIntent intent, [BuildContext? context]) {
    final service = getIt<PlayService>();

    final position = service.positionNotifier.value;
    var newPos = intent.duration;
    if (intent.isIncrease) newPos += position;

    newPos = newPos.clamp(Duration.zero, service.durationNotifier.value);
    service.seek(newPos);
/* TODO::
    return Actions.maybeInvoke(
      context,
      SendPlayingStatusIntent(
        read<PlayStatus>().value,
        newPos,
      ),
    ) as Future<void>?;
    */
  }

  @override
  bool isEnabled(SeekIntent intent, [BuildContext? context]) {
    return getIt<PlayService>().playStatusNotifier.value != PlayStatus.stop;
  }
}

@immutable
class ShareVideoIntent extends Intent {
  final VideoRecord record;
  const ShareVideoIntent(this.record);
}

class ShareVideoAction extends ContextAction<ShareVideoIntent> {
  final ValueNotifier<Watchers> watchersNotifier;

  ShareVideoAction({required this.watchersNotifier});

  @override
  Future<void> invoke(ShareVideoIntent intent, [BuildContext? context]) {
    if (!watchersNotifier.value.isSharing) _initShare();

    final messageData = StartProjectionMessageData(
      sharer: User.fromContext(context!),
      videoRecord: intent.record,
    ).toJson();
    final act =
        Actions.invoke(context, SendMessageIntent(messageData)) as Future;

    return act;
  }

  void _initShare() {
    // TODO: aloha
    watchersNotifier.value = const Watchers([]);
  }
}
