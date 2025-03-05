import 'package:async/async.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
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

@immutable
class LeaveChannelIntent extends Intent {
  const LeaveChannelIntent();
}

class LeaveChannelAction extends ContextAction<LeaveChannelIntent> {
  final WatchersNotifier watchersNotifier;

  LeaveChannelAction({required this.watchersNotifier});

  @override
  Future<void> invoke(LeaveChannelIntent intent,
      [BuildContext? context]) async {
    // Stop playing
    context!.read<WindowTitle>().reset();
    getIt<PlayService>().stop();

    // Send bye message
    if (watchersNotifier.isSharing) {
      final myId = context.read<ClientAccount>().id;
      final messageData = ByeMessageData(userId: myId);
      Actions.invoke(context, SendMessageIntent(messageData));
    }

    // Exit!
    Navigator.of(context).pop();
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

class SyncToggleIntent extends Intent {}

class SyncToggleAction extends ContextAction<SyncToggleIntent> {
  final RestartableTimer saveWatchProgressTimer;
  final SavedPositionNotifier savedPositionNotifier;

  SyncToggleAction({
    required this.saveWatchProgressTimer,
    required this.savedPositionNotifier,
  });

  @override
  void invoke(SyncToggleIntent intent, [BuildContext? context]) {
    final service = getIt<PlayService>();
    service.toggle();

    // Deal with progress saving business
    if (service.playStatusNotifier.value.isPlaying) {
      saveWatchProgressTimer.reset();
      savedPositionNotifier.value = null;
    } else {
      saveWatchProgressTimer.cancel();
    }

    // Try to send play status to channel
    final action = SendPlayStatusAction();
    if (action.isActionEnabled) action.invoke(SendPlayStatusIntent(), context);
  }

  @override
  bool isEnabled(SyncToggleIntent intent, [BuildContext? context]) {
    if (context == null) return false;

    final isBusy = context.read<BusyCount>().isBusy;
    final remoteJustToggled = context.read<RemoteJustToggled>().value;
    return !isBusy && !remoteJustToggled;
  }
}

class SyncSeekIntent extends Intent {
  const SyncSeekIntent(this.duration) : isIncrease = false;
  const SyncSeekIntent.increase(this.duration) : isIncrease = true;
  final Duration duration;
  final bool isIncrease;
}

class SyncSeekAction extends ContextAction<SyncSeekIntent> {
  @override
  void invoke(SyncSeekIntent intent, [BuildContext? context]) {
    final service = getIt<PlayService>();

    final position = service.positionNotifier.value;
    var newPos = intent.duration;
    if (intent.isIncrease) newPos += position;

    newPos = newPos.clamp(Duration.zero, service.durationNotifier.value);
    service.seek(newPos);

    // Try to send play status to channel
    final action = SendPlayStatusAction();
    if (action.isActionEnabled) action.invoke(SendPlayStatusIntent(), context);
  }

  @override
  bool isEnabled(SyncSeekIntent intent, [BuildContext? context]) {
    return getIt<PlayService>().playStatusNotifier.value != PlayStatus.stop;
  }
}

@immutable
class RefreshWatchersIntent extends Intent {
  const RefreshWatchersIntent();
}

class RefreshWatchersAction extends ContextAction<RefreshWatchersIntent> {
  final WatchersNotifier watchersNotifier;

  RefreshWatchersAction({required this.watchersNotifier});

  @override
  void invoke(RefreshWatchersIntent intent, [BuildContext? context]) {
    final messageData = AlohaMessageData(user: User.fromContext(context!));
    Actions.invoke(context, SendMessageIntent(messageData));

    watchersNotifier.value = [User.fromContext(context)];
  }
}

@immutable
class ShareVideoIntent extends Intent {
  final VideoRecord record;
  const ShareVideoIntent(this.record);
}

class ShareVideoAction extends ContextAction<ShareVideoIntent> {
  final VoidCallback initShare;

  ShareVideoAction({required this.initShare});

  @override
  Future<void> invoke(ShareVideoIntent intent, [BuildContext? context]) {
    if (context!.read<List<User>?>() == null) initShare();

    final messageData = StartProjectionMessageData(
      sharer: User.fromContext(context),
      videoRecord: intent.record,
    );
    final act =
        Actions.invoke(context, SendMessageIntent(messageData)) as Future;

    return act;
  }
}

@immutable
class AskPositionIntent extends Intent {
  const AskPositionIntent();
}

class AskPositionAction extends ContextAction<AskPositionIntent> {
  @override
  void invoke(AskPositionIntent intent, [BuildContext? context]) {
    final messageData = WhereMessageData();
    Actions.invoke(context!, SendMessageIntent(messageData));
  }
}

@immutable
class SendPlayStatusIntent extends Intent {}

class SendPlayStatusAction extends ContextAction<SendPlayStatusIntent> {
  @override
  void invoke(SendPlayStatusIntent intent, [BuildContext? context]) {
    final playService = getIt<PlayService>();
    final messageData = PlayAtMessageData(
      sender: User.fromContext(context!),
      position: playService.positionNotifier.value,
      isPlaying: playService.playStatusNotifier.value.isPlaying,
      when: DateTime.now().toUtc(),
    );
    Actions.invoke(context, SendMessageIntent(messageData));
  }

  @override
  bool isEnabled(SendPlayStatusIntent intent, [BuildContext? context]) {
    return context?.read<List<User>?>() != null;
  }
}
