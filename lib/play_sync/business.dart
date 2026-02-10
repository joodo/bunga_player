import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
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
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/dialogs/open_video/direct_link.dart';
import 'package:bunga_player/screens/dialogs/video_conflict.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/utils/extensions/file.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/chat/client/client.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/ui/shortcuts.dart';

// Data types

class RemoteJustToggled {
  final bool value;
  const RemoteJustToggled(this.value);
}

typedef ChannelSubtitle = ({String title, String url, User sharer});

class SubtitleTrackIdOfUrl {
  final value = <String, String>{};
}

class WatcherBufferingStatusNotifier extends ChangeNotifier {
  final Set<String> _bufferingIds = {};
  void setBuffering(String userId, bool isBuffering) {
    if (isBuffering && _bufferingIds.add(userId) ||
        !isBuffering && _bufferingIds.remove(userId)) {
      notifyListeners();
    }
  }

  Iterable<String> get bufferingUserIds => _bufferingIds;
  set bufferingUserIds(Iterable<String> values) {
    _bufferingIds.clear();
    _bufferingIds.addAll(values);
    notifyListeners();
  }

  bool get isAnyBuffering => _bufferingIds.isNotEmpty;

  bool isBuffering(String userId) => _bufferingIds.contains(userId);

  @override
  String toString() => bufferingUserIds.toString();
}

// Actions

class JoinInIntent extends Intent {
  final VideoRecord? myRecord;

  const JoinInIntent({this.myRecord});
}

class JoinInAction extends ContextAction<JoinInIntent> {
  @override
  void invoke(JoinInIntent intent, [BuildContext? context]) {
    final projection = intent.myRecord == null
        ? null
        : StartProjectionMessageData(videoRecord: intent.myRecord!);
    final data = JoinInMessageData(
      user: User.of(context!),
      myShare: projection,
    );
    context.sendMessage(data);
  }
}

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

// Wrapper

class PlaySyncBusiness extends SingleChildStatefulWidget {
  const PlaySyncBusiness({super.key, super.child});

  @override
  State<PlaySyncBusiness> createState() => _PlaySyncBusinessState();
}

class _PlaySyncBusinessState extends SingleChildState<PlaySyncBusiness> {
  // Anti-spam for remote toggle
  final _remoteJustToggledNotifier = AutoResetNotifier(
    const Duration(seconds: 1),
  );

  // Chat
  late final StreamSubscription _streamSubscription;

  // Player status
  final _playerBufferingNotifier = getIt<PlayService>().isBufferingNotifier;
  final _watchersBufferStatusNotifier = WatcherBufferingStatusNotifier()
    ..watchInConsole('Watchers Sync Status');

  late final _busyNotifier = context.read<BusyStateNotifier>();

  // Seeking business
  bool _seeking = false;

  void _updateBusyState() {
    _watchersBufferStatusNotifier.isAnyBuffering
        ? _busyNotifier.add('watchers buffering')
        : _busyNotifier.remove('watchers buffering');
  }

  // Subtitle sharing
  final _channelSubtitleNotifier = ValueNotifier<ChannelSubtitle?>(null)
    ..watchInConsole('Channel Subtitle');

  @override
  void initState() {
    super.initState();

    final read = context.read;

    final myId = read<ClientAccount>().id;

    final messageStream = read<Stream<Message>>();
    _streamSubscription = messageStream.listen((message) {
      switch (message.data['code']) {
        case WhoAreYouMessageData.messageCode:
          _dealWithWhoAreYou();
        case StartProjectionMessageData.messageCode:
          final data = StartProjectionMessageData.fromJson(message.data);
          _handleProjection(
            message.sender,
            data.videoRecord,
            data.position,
            myId,
          );
        case HereAreMessageData.messageCode:
          final data = HereAreMessageData.fromJson(message.data);
          _handleHereAre(data.buffering);
        case BufferStateChangedMessageData.messageCode:
          final isBuffering = BufferStateChangedMessageData.fromJson(
            message.data,
          ).isBuffering;
          _handleSyncStatus(message.sender, isBuffering);
        case PlayAtMessageData.messageCode:
          final data = PlayAtMessageData.fromJson(message.data);
          _handlePlayAt(message.sender, data.isPlay, data.position);
        case SetPlaybackMessageData.messageCode:
          if (message.sender.id == myId) break;
          final isPlay = SetPlaybackMessageData.fromJson(message.data).isPlay;

          final manager = read<PlaySyncMessageManager>();
          final name = message.sender.name;
          manager.show('$name ${isPlay ? '播放' : '暂停'}了视频');

          _remoteJustToggledNotifier.mark();
        case SeekMessageData.messageCode:
          if (message.sender.id == myId) break;

          final manager = read<PlaySyncMessageManager>();
          final name = message.sender.name;
          manager.show('$name 调整了进度');
        case ShareSubMessageData.messageCode:
          _dealWithSubSharing(
            sharer: message.sender,
            data: ShareSubMessageData.fromJson(message.data),
          );
        case ResetMessageData.messageCode:
          if (mounted) Navigator.of(context).pop();
      }
    });

    _playerBufferingNotifier.addListener(_sendBufferingStatus);
    _watchersBufferStatusNotifier.addListener(_updateBusyState);

    final playService = getIt<PlayService>();
    playService.positionNotifier.addListener(_silentCatchUp);
    playService.finishNotifier.addListener(_sendFinishMessage);
  }

  @override
  void dispose() {
    _playerBufferingNotifier.removeListener(_sendBufferingStatus);
    _watchersBufferStatusNotifier.removeListener(_updateBusyState);

    final playService = getIt<PlayService>();
    playService.positionNotifier.removeListener(_silentCatchUp);
    playService.finishNotifier.removeListener(_sendFinishMessage);

    _remoteJustToggledNotifier.dispose();
    _channelSubtitleNotifier.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    // Capture shortcuts before play business
    final shortcuts = child!.applyShortcuts({
      ShortcutKey.forward5Sec: SeekForwardIntent(Duration(seconds: 5)),
      ShortcutKey.backward5Sec: SeekForwardIntent(Duration(seconds: -5)),
      ShortcutKey.togglePlay: ToggleIntent(),
    });

    final actions = shortcuts.actions(
      actions: {
        ToggleIntent: CallbackAction<ToggleIntent>(
          onInvoke: (intent) {
            if (_remoteJustToggledNotifier.value) return;

            final playService = getIt<PlayService>();
            final messageData = SetPlaybackMessageData(
              isPlay: !playService.playStatusNotifier.value.isPlaying,
            );
            context.sendMessage(messageData);
            return;
          },
        ),
        SeekForwardIntent: CallbackAction<SeekForwardIntent>(
          onInvoke: _applySeekAndSendMessage,
        ),
        SeekStartIntent: CallbackAction<SeekStartIntent>(
          onInvoke: (intent) {
            // Don't wait me...
            context.sendMessage(BufferStateChangedMessageData(false));
            _seeking = true;
            return;
          },
        ),
        SeekEndIntent: CallbackAction<SeekEndIntent>(
          onInvoke: (intent) {
            _applySeekAndSendMessage(intent);
            _seeking = false;
            _sendBufferingStatus();
            return;
          },
        ),
        ShareVideoIntent: ShareVideoAction(),
        JoinInIntent: JoinInAction(),
      },
    );

    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _channelSubtitleNotifier),
        ListenableProvider.value(value: _watchersBufferStatusNotifier),
        Provider(create: (context) => SubtitleTrackIdOfUrl()),
      ],
      child: actions,
    );
  }

  void _applySeekAndSendMessage(SeekIntent intent) {
    final player = getIt<PlayService>();
    player.seek(intent.position);

    final messageData = SeekMessageData(position: intent.position);
    context.sendMessage(messageData);
  }

  void _dealWithWhoAreYou() {
    // TODO: useless?
    final data = JoinInMessageData(user: User.fromContext(context));
    context.sendMessage(data);
  }

  void _handleProjection(
    User sender,
    VideoRecord videoRecord,
    Duration start,
    String myId,
  ) async {
    final currentRecord = context.read<PlayPayload?>()?.record;

    if (sender.id != myId && currentRecord != null) {
      context.read<PlaySyncMessageManager>().show('${sender.name} 分享了视频');
    }

    VideoRecord? newRecord = videoRecord;

    if (newRecord.source == 'local' && !File(newRecord.path).existsSync()) {
      newRecord = null;

      // If current playing is local, try to find file in same dir
      if (currentRecord?.source == 'local') {
        final currentDir = path_tool.dirname(currentRecord!.path);
        final newBasename = path_tool.basename(videoRecord.path);
        final sameDirPath = path_tool.join(currentDir, newBasename);
        if (File(sameDirPath).existsSync()) {
          newRecord = videoRecord.copyWith(path: sameDirPath);
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
        if (!videoRecord.id.endsWith(crc)) {
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

        newRecord = videoRecord.copyWith(path: selectedPath);
      }
    }

    Actions.invoke(context, OpenVideoIntent.record(newRecord, start: start));
  }

  void _handleHereAre(List<String> buffering) {
    _watchersBufferStatusNotifier.bufferingUserIds = buffering;
  }

  void _handleSyncStatus(User sender, bool status) {
    _watchersBufferStatusNotifier.setBuffering(sender.id, status);
  }

  void _handlePlayAt(User sender, bool isPlay, Duration position) async {
    final playService = getIt<PlayService>();

    // Seek
    final localPosition = playService.positionNotifier.value;
    final shouldSeek =
        !_seeking &&
        (isPlay
            ? !localPosition.near(
                position,
                tolerance: const Duration(seconds: 2),
              )
            : localPosition != position);
    if (shouldSeek) {
      await playService.seek(position);
      _catchUpTarget = null;
    } else {
      if (!_seeking && !localPosition.near(position)) {
        // Not "near" enough, change playback rate instead of seeking to avoid jarring
        _catchUpTarget = _CatchUpTarget(position);
      }
    }

    // Toggle play/pause
    final localPlay = playService.playStatusNotifier.value.isPlaying;
    final shouldToggle = isPlay != localPlay;
    if (shouldToggle && mounted) {
      Actions.invoke(context, ToggleIntent());
    }
  }

  void _dealWithSubSharing({
    required User sharer,
    required ShareSubMessageData data,
  }) {
    context.read<PlaySyncMessageManager>().show('${sharer.name} 分享了字幕');
    _channelSubtitleNotifier.value = (
      title: data.title,
      url: data.url,
      sharer: sharer,
    );
  }

  void _sendBufferingStatus() {
    if (_seeking) return;

    final buffering = _playerBufferingNotifier.value;
    final data = BufferStateChangedMessageData(buffering);
    context.sendMessage(data);
  }

  // Silent Catch-Up
  _CatchUpTarget? _catchUpTarget;
  void _silentCatchUp() {
    final playService = getIt<PlayService>();

    if (_catchUpTarget == null) {
      playService.playbackRateNotifier.value = 1.0;
      return;
    }

    final position = playService.positionNotifier.value;
    final comparison = _catchUpTarget!.compareTo(position);
    switch (comparison) {
      case < 0:
        playService.playbackRateNotifier.value = 0.95;
      case 0:
        _catchUpTarget = null;
        print('finish');
      case > 0:
        playService.playbackRateNotifier.value = 1.05;
    }
  }

  // Finish
  void _sendFinishMessage() {
    context.sendMessage(PlayFinishedMessageData());
  }
}

class _CatchUpTarget {
  final _createdAt = DateTime.now();
  final Duration _target;

  _CatchUpTarget(this._target);

  int compareTo(Duration other) {
    final now = DateTime.now();
    final elapsed = now.difference(_createdAt);
    final currentTarget = _target + elapsed;

    print((currentTarget - other).inMilliseconds);

    if (currentTarget.near(other)) return 0;
    return currentTarget.compareTo(other);
  }
}

extension WrapPlaySyncBusiness on Widget {
  Widget playSyncBusiness({Key? key}) =>
      PlaySyncBusiness(key: key, child: this);
}
