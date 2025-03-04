import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:async/async.dart';
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
import 'package:bunga_player/utils/extensions/file.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:path/path.dart' as path_tool;
import 'package:provider/provider.dart';

import 'actions.dart';
import 'panel/panel.dart';

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

class PlayScreenBusiness extends SingleChildStatefulWidget {
  const PlayScreenBusiness({super.key, super.child});

  @override
  State<PlayScreenBusiness> createState() => _PlayScreenBusinessState();
}

class WatchersNotifier extends ValueNotifier<List<User>?> {
  WatchersNotifier() : super(null);
  bool get isSharing => value != null;

  void addUser(User user) {
    if (containsId(user.id)) return;
    value = [...value!, user];
  }

  void removeUser(String id) {
    value = [...value!..removeWhere((e) => e.id == id)];
  }

  bool containsId(String id) {
    return value?.any((element) => element.id == id) ?? false;
  }
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
  final _watchersNotifier = WatchersNotifier()..watchInConsole('Watchers');
  late final _refreshWatchersAction =
      RefreshWatchersAction(watchersNotifier: _watchersNotifier);
  late final _shareVideoAction = ShareVideoAction(
    watchersNotifier: _watchersNotifier,
    refreshAction: _refreshWatchersAction,
  );
  late final List<StreamSubscription> _streamSubscriptions;

  @override
  void initState() {
    super.initState();

    _isVideoBufferingNotifier.addListener(_updateBusyCount);

    // Play url
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final argument = ModalRoute.of(context)?.settings.arguments;
      if (argument is OpenVideoDialogResult) {
        _openVideoAction
            .invoke(
          OpenVideoIntent.url(argument.url),
          context,
        )
            .then(
          (payload) {
            if (mounted && !argument.onlyForMe) {
              _shareVideoAction.invoke(
                ShareVideoIntent(payload.record),
                context,
              );
            }
          },
        );
      } else if (argument is VideoRecord) {
        _openVideoAction.invoke(
          OpenVideoIntent.record(argument),
          context,
        );
        _refreshWatchersAction.invoke(RefreshWatchersIntent(), context);
      }
    });

    // Listen to changing video
    final myId = context.read<ClientAccount>().id;
    final messageStream = context.read<Stream<Message>>();
    _streamSubscriptions = [
      messageStream
          .where(
            (message) =>
                message.data['type'] ==
                    StartProjectionMessageData.messageType &&
                message.senderId != myId,
          )
          .map((message) => StartProjectionMessageData.fromJson(message.data))
          .listen(_dealWithProjection),
      messageStream
          .where(
            (message) =>
                message.data['type'] == AlohaMessageData.messageType &&
                message.senderId != myId,
          )
          .map((message) => AlohaMessageData.fromJson(message.data))
          .listen(_dealWithAloha),
      messageStream
          .where(
            (message) =>
                message.data['type'] == HereIsMessageData.messageType &&
                message.senderId != myId,
          )
          .map((message) => HereIsMessageData.fromJson(message.data))
          .listen(_dealWithHereIs),
      messageStream
          .where(
            (message) =>
                message.data['type'] == ByeMessageData.messageType &&
                message.senderId != myId,
          )
          .map((message) => ByeMessageData.fromJson(message.data))
          .listen(_dealWithBye),
    ];

    // Init late variables
    _history;
    _isVideoBufferingNotifier;
  }

  @override
  void dispose() async {
    _playPayloadNotifier.dispose();
    _busyCountNotifer.dispose();
    _panelNotifier.dispose();
    _watchersNotifier.dispose();
    _isVideoBufferingNotifier.removeListener(_updateBusyCount);

    _saveWatchProgressTimer.cancel();
    _history.save();
    _savedPositionNotifier.dispose();

    for (final subscription in _streamSubscriptions) {
      await subscription.cancel();
    }

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
        ValueListenableProvider.value(value: _panelNotifier),
        ValueListenableProvider.value(value: _watchersNotifier),
      ],
      //builder: (context, child) => child!,
      child: child!.actions(
        actions: {
          RefreshDirIntent: RefreshDirAction(dirInfoNotifier: _dirInfoNotifier),
          ShowPanelIntent: ShowPanelAction(widgetNotifier: _panelNotifier),
          ClosePanelIntent: ClosePanelAction(widgetNotifier: _panelNotifier),
          OpenVideoIntent: _openVideoAction,
          LeaveChannelIntent:
              LeaveChannelAction(watchersNotifier: _watchersNotifier),
          ToggleIntent: ToggleAction(
            saveWatchProgressTimer: _saveWatchProgressTimer,
            savedPositionNotifier: _savedPositionNotifier,
          ),
          SeekIntent: SeekAction(),
          ShareVideoIntent: _shareVideoAction,
          RefreshWatchersIntent: _refreshWatchersAction,
        },
      ),
    );
  }

  void _dealWithAloha(AlohaMessageData data) {
    _watchersNotifier.addUser(data.user);

    final messageData = HereIsMessageData(
      user: User.fromContext(context),
      isTalking: false,
    );
    Actions.invoke(context, SendMessageIntent(messageData));
  }

  void _dealWithHereIs(HereIsMessageData data) {
    _watchersNotifier.addUser(data.user);
  }

  void _dealWithBye(ByeMessageData data) {
    _watchersNotifier.removeUser(data.userId);
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
