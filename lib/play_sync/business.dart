import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:path/path.dart' as path_tool;
import 'package:provider/provider.dart';

import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/history.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/dialogs/open_video/direct_link.dart';
import 'package:bunga_player/screens/dialogs/video_conflict.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/utils/extensions/file.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';

// Data types

@immutable
class RemoteJustToggled {
  final bool value;
  const RemoteJustToggled(this.value);
}

// Actions

class SyncToggleAction extends ContextAction<ToggleIntent> {
  SyncToggleAction();

  @override
  void invoke(ToggleIntent intent, [BuildContext? context]) {
    final remoteJustToggled = context!.read<RemoteJustToggled>().value;
    if (remoteJustToggled) return;

    // Toggle is invoked by me, not remote, so I can forget saved position.
    Actions.maybeInvoke(context, intent);

    if (intent.forgetSavedPosition) {
      // Forget saved position means this action is invoked by myself
      // Try to send play status to channel
      SendPlayStatusAction().invoke(SendPlayStatusIntent(), context);
    }
  }
}

class SyncSeekAction extends ContextAction<SeekIntent> {
  @override
  void invoke(SeekIntent intent, [BuildContext? context]) {
    Actions.maybeInvoke(context!, intent);

    // Try to send play status to channel
    final action = SendPlayStatusAction();
    if (action.isActionEnabled) action.invoke(SendPlayStatusIntent(), context);
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

@immutable
class ShareVideoIntent extends Intent {
  final VideoRecord record;
  const ShareVideoIntent(this.record);
}

class ShareVideoAction extends ContextAction<ShareVideoIntent> {
  final VoidCallback shouldAnswerWhereSetter;
  ShareVideoAction({required this.shouldAnswerWhereSetter});

  @override
  Future<void> invoke(ShareVideoIntent intent, [BuildContext? context]) {
    // I shared the video, I should answer others
    shouldAnswerWhereSetter();

    final messageData = StartProjectionMessageData(
      sharer: User.fromContext(context!),
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

// Wrapper

class PlaySyncBusiness extends SingleChildStatefulWidget {
  const PlaySyncBusiness({super.key, super.child});

  @override
  State<PlaySyncBusiness> createState() => _PlaySyncBusinessState();
}

class _PlaySyncBusinessState extends SingleChildState<PlaySyncBusiness> {
  final _remoteJustToggledNotifier = AutoResetNotifier(
    const Duration(seconds: 1),
  );
  // Chat
  late final StreamSubscription _streamSubscription;

  bool _shouldAnswerWhere = false;

  @override
  void initState() {
    super.initState();

    final myId = context.read<ClientAccount>().id;
    final messageStream = context
        .read<Stream<Message>>()
        .where((message) => message.senderId != myId);

    _streamSubscription = messageStream.listen((message) {
      switch (message.data['type']) {
        case StartProjectionMessageData.messageType:
          _dealWithProjection(
            StartProjectionMessageData.fromJson(message.data),
          );
        case WhereMessageData.messageType:
          _dealWithWhere(
            WhereMessageData.fromJson(message.data),
          );
        case PlayAtMessageData.messageType:
          _dealWithPlayAt(
            PlayAtMessageData.fromJson(message.data),
          );
      }
    });
  }

  @override
  void dispose() {
    _remoteJustToggledNotifier.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ValueListenableProxyProvider(
          valueListenable: _remoteJustToggledNotifier,
          proxy: (value) => RemoteJustToggled(value),
        ),
      ],
      child: child?.actions(actions: {
        ToggleIntent: SyncToggleAction(),
        SeekIntent: SyncSeekAction(),
        ShareVideoIntent: ShareVideoAction(
          shouldAnswerWhereSetter: () => _shouldAnswerWhere = true,
        ),
        AskPositionIntent: AskPositionAction(),
      }),
    );
  }

  void _dealWithProjection(StartProjectionMessageData data) async {
    var newRecord = data.videoRecord;

    if (newRecord.source == 'local' && !File(newRecord.path).existsSync()) {
      // If current playing is local, try to find file in same dir
      final currentRecord = context.read<PlayPayload?>()?.record;
      if (currentRecord?.source == 'local') {
        final currentDir = path_tool.dirname(currentRecord!.path);
        final newBasename = path_tool.basename(newRecord.path);
        if (!File(path_tool.join(currentDir, newBasename)).existsSync()) {
          // Same dir file not exist too
          final selectedPath = await LocalVideoEntryDialog.exec();
          if (selectedPath == null) return;

          final file = File(selectedPath);
          final crc = await file.crcString();

          if (!mounted) return;
          // New selected file conflict, needs confirm
          if (!currentRecord.id.endsWith(crc)) {
            final confirmOpen = await showModal<bool>(
              context: context,
              builder: VideoConflictDialog.builder,
            );
            if (!mounted || confirmOpen != true) return;
          }

          newRecord = newRecord.copyWith(path: selectedPath);
        }
      }
    }

    Actions.invoke(context, OpenVideoIntent.record(newRecord));
  }

  void _dealWithWhere(WhereMessageData data) {
    if (!_shouldAnswerWhere) return;

    final history = context.read<History>().value;
    final record = context.read<PlayPayload?>()?.record;
    // No history, not even played
    if (!history.containsKey(record?.id)) return;

    final action = SendPlayStatusAction();
    action.invoke(SendPlayStatusIntent(), context);
  }

  void _dealWithPlayAt(PlayAtMessageData data) {
    // Follow play status
    String? toastType;

    // If apply status is because asking where, then don't show snack bar
    if (!_shouldAnswerWhere) {
      toastType = 'none';
      _shouldAnswerWhere = true;
    }

    final playService = getIt<PlayService>();
    if (data.isPlaying != playService.playStatusNotifier.value.isPlaying) {
      toastType ??= 'toggle';
      Actions.invoke(context, ToggleIntent());
      _remoteJustToggledNotifier.mark();
    }

    Duration remotePosition = data.position;
    if (data.isPlaying) {
      remotePosition += DateTime.now().toUtc().difference(data.when);
    }
    if (data.isPlaying &&
            !playService.positionNotifier.value.near(remotePosition) ||
        playService.positionNotifier.value != remotePosition) {
      toastType ??= 'seek';
      playService.seek(remotePosition);
    }

    toastType ??= 'none';

    final toast = getIt<Toast>();
    final name = data.sender.name;
    switch (toastType) {
      case 'toggle':
        toast.show('$name ${data.isPlaying ? '播放' : '暂停'}了视频');
      case 'seek':
        toast.show('$name 调整了进度');
    }
  }
}

extension WrapPlaySyncBusiness on Widget {
  Widget playSyncBusiness({Key? key}) =>
      PlaySyncBusiness(key: key, child: this);
}
