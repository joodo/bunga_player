import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/play/models/history.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/play/providers.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/dialogs/open_video/direct_link.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/screens/dialogs/video_conflict.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/utils/extensions/file.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/actions.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:path/path.dart' as path_tool;
import 'package:provider/provider.dart';

import 'actions.dart';
import 'panel/panel.dart';
import 'player_screen.dart';

@immutable
class BusyCount {
  final int _count;
  const BusyCount(this._count);

  bool get isBusy => _count > 0;
  BusyCount get increase => BusyCount(_count + 1);
  BusyCount get decrease => BusyCount(_count - 1);
}

@immutable
class DanmakuVisible {
  final bool value;
  const DanmakuVisible(this.value);
}

class SavedPositionNotifier extends ValueNotifier<Duration?> {
  SavedPositionNotifier() : super(null);
}

class WatchersNotifier extends ValueNotifier<List<User>?> {
  WatchersNotifier() : super(null);
  bool get isSharing => value != null;

  void addUser(User user) {
    if (containsId(user.id)) return;
    value = [...value!, user];
    AudioPlayer().play(
      AssetSource('sounds/user_join.mp3'),
      mode: PlayerMode.lowLatency,
    );
  }

  void removeUser(String id) {
    final index = value!.indexWhere((e) => e.id == id);
    if (index < 0) return;

    value = [...value!..removeAt(index)];
    AudioPlayer().play(
      AssetSource('sounds/user_leave.mp3'),
      mode: PlayerMode.lowLatency,
    );
  }

  bool containsId(String id) {
    return value?.any((element) => element.id == id) ?? false;
  }
}

class RecentPopmojisNotifier extends ValueNotifier<List<String>> {
  RecentPopmojisNotifier()
      : super(["🎆", "😆", "😭", "😍", "🤤", "🫣", "🤮", "🤡", "🔥"]) {
    bindPreference<List<String>>(
      preferences: getIt<Preferences>(),
      key: 'recent_popmojis',
      load: (pref) => value,
      update: (value) => value,
    );
  }
}

@immutable
class RemoteJustToggled {
  final bool value;
  const RemoteJustToggled(this.value);
}

class PlayScreenBusiness extends SingleChildStatefulWidget {
  const PlayScreenBusiness({super.key, super.child});

  @override
  State<PlayScreenBusiness> createState() => _PlayScreenBusinessState();
}

@immutable
class TalkerId {
  final String value;
  const TalkerId(this.value);
}

class _PlayScreenBusinessState extends SingleChildState<PlayScreenBusiness> {
  // Play payload
  final _playPayloadNotifier = ValueNotifier<PlayPayload?>(null);
  final _dirInfoNotifier = ValueNotifier<DirInfo?>(null);
  late final _openVideoAction = OpenVideoAction(
    busyCountNotifier: _busyCountNotifer,
    payloadNotifer: _playPayloadNotifier,
    dirInfoNotifier: _dirInfoNotifier,
    savedPositionNotifier: _savedPositionNotifier,
  );

  // Progress indicator
  final _busyCountNotifer = ValueNotifier(const BusyCount(0));
  late final _isVideoBufferingNotifier = context.read<PlayIsBuffering>();
  void _updateBusyCount() {
    _busyCountNotifer.value = _isVideoBufferingNotifier.value
        ? _busyCountNotifer.value.increase
        : _busyCountNotifer.value.decrease;
  }

  // Panel
  final _panelNotifier = ValueNotifier<Panel?>(null);

  // Danmaku Control
  final _showDanmakuControlNotifier = ValueNotifier(false);

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

  // Chat
  StreamSubscription? _streamSubscription;

  // Watchers
  final _watchersNotifier = WatchersNotifier()..watchInConsole('Watchers');
  late final _refreshWatchersAction =
      RefreshWatchersAction(watchersNotifier: _watchersNotifier);
  late final _shareVideoAction = ShareVideoAction(initShare: _initShare);

  // Play position
  bool _shouldAnswerWhere = false;

  final _remoteJustToggledNotifier = AutoResetNotifier(
    const Duration(seconds: 1),
  );

  late final _toggleAction = ToggleAction(
    saveWatchProgressTimer: _saveWatchProgressTimer,
    savedPositionNotifier: _savedPositionNotifier,
  );

  // Popmojis
  final _recentPopmojis = RecentPopmojisNotifier();

  // Talk
  final _talkerIdsNotifier = ValueNotifier<Set<String>>({})
    ..watchInConsole('Talkers Id');

  @override
  void initState() {
    super.initState();

    // UI
    _isVideoBufferingNotifier.addListener(_updateBusyCount);
    _showDanmakuControlNotifier.addListener(
      () => getIt<Toast>().setOffset(
          _showDanmakuControlNotifier.value ? PlayerScreen.danmakuHeight : 0),
    );

    // Play url
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final argument = ModalRoute.of(context)?.settings.arguments;
      if (argument is OpenVideoDialogResult) {
        // Join in by open video from dialog
        _openVideoAction
            .invoke(
          OpenVideoIntent.url(argument.url),
          context,
        )
            .then(
          (payload) {
            if (mounted && !argument.onlyForMe) {
              // I shared the video, I should answer others
              _shouldAnswerWhere = true;

              _shareVideoAction.invoke(
                ShareVideoIntent(payload.record),
                context,
              );
            }
          },
        );
      } else if (argument is VideoRecord) {
        // Join in by "Channel Card" in Welcome screen
        await _openVideoAction.invoke(
          OpenVideoIntent.record(argument),
          context,
        );

        if (!mounted) return;
        AskPositionAction().invoke(AskPositionIntent(), context);
        _initShare();
      }
    });

    // Init late variables
    _history;
  }

  @override
  void dispose() {
    _playPayloadNotifier.dispose();
    _busyCountNotifer.dispose();
    _panelNotifier.dispose();
    _watchersNotifier.dispose();
    _remoteJustToggledNotifier.dispose();
    _talkerIdsNotifier.dispose();

    _isVideoBufferingNotifier.removeListener(_updateBusyCount);

    _saveWatchProgressTimer.cancel();
    _history.save();
    _savedPositionNotifier.dispose();

    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _panelNotifier),
        ValueProxyListenableProvider(
          valueListenable: _showDanmakuControlNotifier,
          proxy: (value) => DanmakuVisible(value),
        ),
        ValueListenableProvider.value(value: _playPayloadNotifier),
        ChangeNotifierProvider.value(value: _savedPositionNotifier),
        ValueListenableProvider.value(value: _dirInfoNotifier),
        ValueListenableProvider.value(value: _busyCountNotifer),
        ValueListenableProvider.value(value: _watchersNotifier),
        ValueProxyListenableProvider(
          valueListenable: _remoteJustToggledNotifier,
          proxy: (value) => RemoteJustToggled(value),
        ),
        ChangeNotifierProvider.value(value: _recentPopmojis),
        ValueProxyListenableProvider(
          valueListenable: _talkerIdsNotifier,
          proxy: (value) => value.map((e) => TalkerId(e)).toList(),
        ),
      ],
      child: child!.actions(
        actions: {
          RefreshDirIntent: RefreshDirAction(dirInfoNotifier: _dirInfoNotifier),
          ShowPanelIntent: ShowPanelAction(widgetNotifier: _panelNotifier),
          ClosePanelIntent: ClosePanelAction(widgetNotifier: _panelNotifier),
          ToggleDanmakuControlIntent: ToggleDanmakuControlAction(
              showDanmakuControlNotifier: _showDanmakuControlNotifier),
          OpenVideoIntent: _openVideoAction,
          LeaveChannelIntent:
              LeaveChannelAction(watchersNotifier: _watchersNotifier),
          ToggleIntent: _toggleAction,
          SyncSeekIntent: SyncSeekAction(),
          ShareVideoIntent: _shareVideoAction,
          RefreshWatchersIntent: _refreshWatchersAction,
          AskPositionIntent: AskPositionAction(),
          SendPopmojiIntent: SendPopmojiAction(),
          SendDanmakuIntent: SendDanmakuAction(),
        },
      ),
    );
  }

  void _initShare() {
    // Listen to messageStream
    final myId = context.read<ClientAccount>().id;
    final messageStream = context.read<Stream<Message>>();

    _streamSubscription = messageStream.listen((message) {
      switch (message.data['type']) {
        case StartProjectionMessageData.messageType:
          if (message.senderId == myId) break;
          _dealWithProjection(
            StartProjectionMessageData.fromJson(message.data),
          );
        case AlohaMessageData.messageType:
          if (message.senderId == myId) break;
          _dealWithAloha(
            AlohaMessageData.fromJson(message.data),
          );
        case HereIsMessageData.messageType:
          if (message.senderId == myId) break;
          _dealWithHereIs(
            HereIsMessageData.fromJson(message.data),
          );
        case ByeMessageData.messageType:
          if (message.senderId == myId) break;
          _dealWithBye(
            ByeMessageData.fromJson(message.data),
          );
        case WhereMessageData.messageType:
          if (message.senderId == myId) break;
          _dealWithWhere(
            WhereMessageData.fromJson(message.data),
          );
        case PlayAtMessageData.messageType:
          if (message.senderId == myId) break;
          _dealWithPlayAt(
            PlayAtMessageData.fromJson(message.data),
          );
        case TalkStatusMessageData.messageType:
          _dealWithTalkStatus(
            message.senderId,
            TalkStatusMessageData.fromJson(message.data).status,
          );
      }
    });

    // Get watchers
    _refreshWatchersAction.invoke(const RefreshWatchersIntent(), context);
  }

  void _dealWithAloha(AlohaMessageData data) {
    _watchersNotifier.addUser(data.user);

    final me = User.fromContext(context);
    final messageData = HereIsMessageData(
      user: me,
      isTalking: _talkerIdsNotifier.value.contains(me.id),
    );
    Actions.invoke(context, SendMessageIntent(messageData));
  }

  void _dealWithHereIs(HereIsMessageData data) {
    _watchersNotifier.addUser(data.user);
    if (data.isTalking && _talkerIdsNotifier.value.add(data.user.id)) {
      _talkerIdsNotifier.value = {..._talkerIdsNotifier.value};
    }
  }

  void _dealWithBye(ByeMessageData data) {
    _watchersNotifier.removeUser(data.userId);
  }

  void _dealWithWhere(WhereMessageData data) {
    if (!_shouldAnswerWhere) return;

    final history = _history.value;
    final record = _playPayloadNotifier.value?.record;
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
      _toggleAction.invoke(ToggleIntent(), context);
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

  void _dealWithTalkStatus(String senderId, TalkStatus status) {
    switch (status) {
      case TalkStatus.start:
        if (_talkerIdsNotifier.value.add(senderId)) {
          _talkerIdsNotifier.value = {..._talkerIdsNotifier.value};
          AudioPlayer().play(
            AssetSource('sounds/user_speak.mp3'),
            mode: PlayerMode.lowLatency,
          );
        }
      case TalkStatus.end:
        if (_talkerIdsNotifier.value.remove(senderId)) {
          _talkerIdsNotifier.value = {..._talkerIdsNotifier.value};

          final myId = context.read<ClientAccount>().id;
          if (_talkerIdsNotifier.value.length == 1 &&
              _talkerIdsNotifier.value.first == myId) {
            getIt<Toast>().show('通话已结束');
            Actions.invoke(context, const HangUpIntent());
          }
        }
    }
  }

  Future<void> _dealWithProjection(StartProjectionMessageData data) async {
    var newRecord = data.videoRecord;

    if (newRecord.source == 'local' && !File(newRecord.path).existsSync()) {
      // If current playing is local, try to find file in same dir
      final currentRecord = _playPayloadNotifier.value?.record;
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

    return _openVideoAction.invoke(
      OpenVideoIntent.record(newRecord),
      context,
    ) as Future;
  }
}

extension WrapPlayScreenBusiness on Widget {
  Widget playScreenBusiness() => PlayScreenBusiness(child: this);
}
