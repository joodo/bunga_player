import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:bunga_player/chat/client/client.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/ui/shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:path/path.dart' as path_tool;
import 'package:provider/provider.dart';

import 'package:bunga_player/chat/global_business.dart';
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

class RemoteJustToggled {
  final bool value;
  const RemoteJustToggled(this.value);
}

typedef ChannelSubtitle = ({String title, String url, User sharer});

class SubtitleTrackIdOfUrl {
  final value = <String, String>{};
}

class WatcherSyncStatusNotifier extends ChangeNotifier {
  final Map<String, SyncStatus> _syncStatus = {};
  void setSyncStatus(String userId, SyncStatus status) {
    _syncStatus[userId] = status;
    notifyListeners();
  }

  Iterable<String> get bufferingUserIds => _syncStatus.entries
      .where((entry) => entry.value == .buffering)
      .map((entry) => entry.key);
  SyncStatus syncStatusOf(String userId) => _syncStatus[userId] ?? .buffering;
}

// Actions

@immutable
class ShareVideoIntent extends Intent {
  final VideoRecord? record;
  final Uri? url;
  const ShareVideoIntent(this.record) : url = null;
  const ShareVideoIntent.url(this.url) : record = null;
}

class ShareVideoAction extends ContextAction<ShareVideoIntent> {
  ShareVideoAction();

  @override
  Future<void> invoke(ShareVideoIntent intent, [BuildContext? context]) async {
    final client = context!.read<ChatClient?>();
    final record =
        intent.record ?? await PlayPayloadParser(context).parseUrl(intent.url!);

    final data = StartProjectionMessageData(videoRecord: record);
    client!.sendMessage(data.toJson());
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

  // Player status
  final _playerBufferingNotifier = getIt<PlayService>().bufferingNotifier;
  final _watchersSyncStatusNotifier = WatcherSyncStatusNotifier();

  // Subtitle sharing
  final _channelSubtitleNotifier = ValueNotifier<ChannelSubtitle?>(null)
    ..watchInConsole('Channel Subtitle');

  @override
  void initState() {
    super.initState();

    final myId = context.read<ClientAccount>().id;

    final messageStream = context.read<Stream<Message>>();
    _streamSubscription = messageStream.listen((message) {
      switch (message.data['code']) {
        case StartProjectionMessageData.messageCode:
          _dealWithProjection(
            message.sender,
            StartProjectionMessageData.fromJson(message.data),
            myId,
          );
        case HereAreMessageData.messageCode:
          final watchers = HereAreMessageData.fromJson(message.data).watchers;
          _dealWithHereAre(watchers);
        case SyncStatusMessageData.messageCode:
          final status = SyncStatusMessageData.fromJson(message.data).status;
          _dealWithSyncStatus(message.sender, status);
        case WhereMessageData.messageCode:
          _dealWithWhere(WhereMessageData.fromJson(message.data));
        case PlayAtMessageData.messageCode:
          _dealWithPlayAt(PlayAtMessageData.fromJson(message.data));
        case ShareSubMessageData.messageCode:
          _dealWithSubSharing(ShareSubMessageData.fromJson(message.data));
      }
    });

    _playerBufferingNotifier.addListener(_sendBufferingStatus);

    // TODO: useless
    //_fetchPlayStatus();
  }

  @override
  void dispose() {
    _playerBufferingNotifier.removeListener(_sendBufferingStatus);

    _remoteJustToggledNotifier.dispose();
    _channelSubtitleNotifier.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final shortcuts = child!.applyShortcuts({
      ShortcutKey.forward5Sec: SeekIntent.increase(Duration(seconds: 5)),
      ShortcutKey.backward5Sec: SeekIntent.increase(Duration(seconds: -5)),
      ShortcutKey.togglePlay: ToggleIntent(),
    });

    final actions = shortcuts.actions(
      actions: {
        ToggleIntent: CallbackAction<ToggleIntent>(
          onInvoke: (intent) {
            if (_remoteJustToggledNotifier.value) return;
            Actions.invoke(context, intent);
            _sendPlayStatus();
            return;
          },
        ),
        SeekIntent: CallbackAction<SeekIntent>(
          onInvoke: (intent) {
            if (_remoteJustToggledNotifier.value) return;
            Actions.invoke(context, intent);
            _sendPlayStatus();
            return;
          },
        ),
        ShareVideoIntent: ShareVideoAction(),
        AskPositionIntent: AskPositionAction(),
      },
    );

    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _channelSubtitleNotifier),
        ListenableProvider.value(value: _watchersSyncStatusNotifier),
        Provider(create: (context) => SubtitleTrackIdOfUrl()),
        ValueListenableProxyProvider(
          valueListenable: _remoteJustToggledNotifier,
          proxy: (value) => RemoteJustToggled(value),
        ),
      ],
      child: actions,
    );
  }

  void _sendPlayStatus() {
    final playService = getIt<PlayService>();
    final messageData = PlayAtMessageData(
      sender: User.fromContext(context),
      position: playService.positionNotifier.value,
      isPlaying: playService.playStatusNotifier.value.isPlaying,
    );
    Actions.invoke(context, SendMessageIntent(messageData));
  }

  void _dealWithProjection(
    User sender,
    StartProjectionMessageData data,
    String myId,
  ) async {
    if (sender.id != myId) {
      getIt<Toast>().show('${sender.name} 分享了视频');
    }

    VideoRecord? newRecord = data.videoRecord;

    if (newRecord.source == 'local' && !File(newRecord.path).existsSync()) {
      newRecord = null;

      // If current playing is local, try to find file in same dir
      final currentRecord = context.read<PlayPayload?>()?.record;
      if (currentRecord?.source == 'local') {
        final currentDir = path_tool.dirname(currentRecord!.path);
        final newBasename = path_tool.basename(data.videoRecord.path);
        final sameDirPath = path_tool.join(currentDir, newBasename);
        if (File(sameDirPath).existsSync()) {
          newRecord = data.videoRecord.copyWith(path: sameDirPath);
        }
      }

      if (newRecord == null) {
        // Same dir file not exist too, or just not playing local video
        final selectedPath = await LocalVideoDialog.exec();
        if (selectedPath == null) {
          if (mounted) Navigator.of(context).maybePop();
          return;
        }

        final file = File(selectedPath);
        final crc = await file.crcString();

        if (!mounted) return;
        // New selected file conflict, needs confirm
        if (!data.videoRecord.id.endsWith(crc)) {
          final confirmOpen = await showModal<bool>(
            context: context,
            builder: VideoConflictDialog.builder,
          );
          if (!mounted) return;
          if (confirmOpen != true) {
            Navigator.of(context).maybePop();
            return;
          }
        }

        newRecord = data.videoRecord.copyWith(path: selectedPath);
      }
    }

    Actions.invoke(context, OpenVideoIntent.record(newRecord));
  }

  void _dealWithHereAre(List<WatcherInfo> watchers) {
    for (final info in watchers) {
      _watchersSyncStatusNotifier.setSyncStatus(info.user.id, info.syncStatus);
    }
  }

  void _dealWithSyncStatus(User sender, SyncStatus status) {
    _watchersSyncStatusNotifier.setSyncStatus(sender.id, status);
  }

  void _dealWithWhere(WhereMessageData data) {
    if (!_shouldAnswerWhere) return;

    final history = context.read<History>().value;
    final record = context.read<PlayPayload?>()?.record;

    final isPlaying = getIt<PlayService>().playStatusNotifier.value.isPlaying;
    // No history, not even played, should not answer
    if (!isPlaying && !history.containsKey(record?.id)) return;

    _sendPlayStatus();
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

    final remotePosition = data.position;
    final localPosition = playService.positionNotifier.value;
    if (data.isPlaying && !localPosition.near(remotePosition) ||
        localPosition != remotePosition) {
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

  void _dealWithSubSharing(ShareSubMessageData data) {
    getIt<Toast>().show('${data.sharer.name} 分享了字幕');
    _channelSubtitleNotifier.value = (
      title: data.title,
      url: data.url,
      sharer: data.sharer,
    );
  }

  void _sendBufferingStatus() {
    final buffering = _playerBufferingNotifier.value;
    final data = SyncStatusMessageData(buffering ? .buffering : .ready);
    Actions.invoke(context, SendMessageIntent(data));
  }

  /*Future<void> _fetchPlayStatus() async {
    final watchers = context.read<List<User>>();
    final job = Actions.invoke(context, ProjectIntent()) as Future<JsonMap>;
    final json = await job;

    final subtitleInfo = json['subtitle'];
    if (subtitleInfo != null) {
      _channelSubtitleNotifier.value = (
        url: subtitleInfo['file'],
        title: subtitleInfo['name'],
        sharer: watchers.firstWhere((e) => e.id == subtitleInfo['uploader']),
      );
    }
  }*/
}

extension WrapPlaySyncBusiness on Widget {
  Widget playSyncBusiness({Key? key}) =>
      PlaySyncBusiness(key: key, child: this);
}
