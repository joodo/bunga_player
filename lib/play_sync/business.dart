import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nested/nested.dart';
import 'package:path/path.dart' as path_tool;
import 'package:provider/provider.dart';

import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/chat/models/models.dart';
import 'package:bunga_player/chat/client/client.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/models.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/dialogs/open_video/gallery.dart';
import 'package:bunga_player/screens/dialogs/video_conflict.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/ui/shortcuts.dart';

import 'overlay_manager.dart';
import 'actions.dart';

// Data types

class RemoteJustToggled {
  final bool value;
  const RemoteJustToggled(this.value);
}

typedef ChannelSubtitle = ({String title, String url, User sharer});

class SubtitleTrackIdOfUrl {
  final value = <String, String>{};
}

class WatcherPendingIdsNotifier extends ValueNotifier<List<String>> {
  WatcherPendingIdsNotifier() : super([]);
}

enum _Tolerances {
  treatAsSync(Duration(milliseconds: 400)),
  silenceCatchUp(Duration(seconds: 3)),
  waitForOthers(Duration(seconds: 7));

  final Duration duration;
  const _Tolerances(this.duration);
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
  late final _chatClient = context.read<ChatClient>();
  late final StreamSubscription _streamSubscription;

  // Player status
  final _watchersPendingIdsNotifier = WatcherPendingIdsNotifier()
    ..watchInConsole('Watchers Pending Ids');

  // My status
  static const _statusSendInterval = Duration(seconds: 1);
  late final _statusSyncTimer = RestartableTimer(
    _statusSendInterval,
    _sendPendingStatus,
  );
  late final _playbackOverlay = PlaybackOverlayManager(
    context: context,
    pendingPlayShowDelay: _statusSendInterval,
  );

  // Seeking business
  final _isChannelSeeking = AutoResetNotifier(5.seconds);
  bool _isSlideSeeking = false;
  Timer? _resetSlideSeekingTimer;

  // Subtitle sharing
  final _channelSubtitleNotifier = ValueNotifier<ChannelSubtitle?>(null)
    ..watchInConsole('Channel Subtitle');

  @override
  void initState() {
    super.initState();

    _streamSubscription = context.read<Stream<Message>>().listen(
      _handleMessage,
    );

    final player = MediaPlayer.i;
    player.finishNotifier.addListener(_sendFinishMessage);

    _statusSyncTimer.reset();

    _chatClient.isConnectedNotifier.addListener(_rejoinIfConnected);
  }

  @override
  void dispose() {
    final player = MediaPlayer.i;
    player.finishNotifier.removeListener(_sendFinishMessage);

    _remoteJustToggledNotifier.dispose();
    _channelSubtitleNotifier.dispose();
    _isChannelSeeking.dispose();
    _streamSubscription.cancel();

    _statusSyncTimer.cancel();
    _resetSlideSeekingTimer?.cancel();

    _chatClient.isConnectedNotifier.removeListener(_rejoinIfConnected);

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    // Capture shortcuts before play business
    final shortcuts = child!.applyShortcuts({
      ShortcutKey.forward5Sec: SeekForwardIntent(Duration(seconds: 5)),
      ShortcutKey.backward5Sec: SeekForwardIntent(Duration(seconds: -5)),
      ShortcutKey.togglePlay: IndirectToggleIntent(),
    });

    final actions = shortcuts.actions(
      actions: {
        OpenVideoIntent: OpenVideoBeforeShareAction(),
        IndirectToggleIntent: IndirectToggleAction(
          remoteJustToggled: _remoteJustToggledNotifier,
          playbackOverlay: _playbackOverlay,
        ),
        DirectSetPlaybackIntent: DirectSetPlaybackAction(
          remoteJustToggled: _remoteJustToggledNotifier,
          playbackOverlay: _playbackOverlay,
        ),
        SeekForwardIntent: SyncSeekForwardAction(),
        SeekStartIntent: SyncSeekStartAction(onSeekStart: _startSlideSeeking),
        SeekEndIntent: SyncSeekEndAction(onSeekEnd: _endSlideSeeking),
        ShareVideoIntent: ShareVideoAction(),
        JoinInIntent: JoinInAction(),
      },
    );

    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _channelSubtitleNotifier),
        ListenableProvider.value(value: _watchersPendingIdsNotifier),
        Provider(create: (context) => SubtitleTrackIdOfUrl()),
      ],
      child: actions,
    );
  }

  void _handleMessage(Message message) {
    final read = context.read;

    switch (message.data) {
      case StartProjectionMessageData(:final videoRecord, :final position):
        _handleProjection(message.sender, videoRecord, position);
      case HereAreMessageData(:final buffering):
        _updatePendingIds(buffering);
      case ChannelStatusMessageData(
        :final playStatus,
        :final position,
        :final watcherIds,
        :final readyIds,
      ):
        _handleChannelStatus(message.sender, playStatus, position);

        final pendings = watcherIds
            .toSet()
            .difference(readyIds.toSet())
            .toList();
        _updatePendingIds(pendings);
      case PlayMessageData():
        if (message.sender.isCurrent(context)) break;

        final manager = read<SyncMessageEvent>();
        final name = message.sender.name;
        manager.fire('$name 播放了视频');
        _playbackOverlay.show(.pendingPlaying);

        _remoteJustToggledNotifier.mark();
      case PauseMessageData(:final position):
        if (message.sender.isCurrent(context)) break;

        // Paused by user, not by waiting pending
        // So pause immediately and seek, do not wait for channel status message
        MediaPlayer.i.pause();
        if (MediaPlayer.i.positionNotifier.value.near(
          position,
          tolerance: _Tolerances.treatAsSync.duration,
        )) {
          MediaPlayer.i.seek(position);
        }

        final manager = read<SyncMessageEvent>();
        final name = message.sender.name;
        manager.fire('$name 暂停了视频');
        _playbackOverlay.show(.pause);

        _remoteJustToggledNotifier.mark();
      case SeekMessageData(:final position):
        if (message.sender.isCurrent(context)) break;

        final manager = read<SyncMessageEvent>();
        final name = message.sender.name;
        manager.fire('$name 调整了进度');

        // Seek immediately, do not wait for channel status message
        MediaPlayer.i.seek(position);

        _isChannelSeeking.mark();
      case ShareSubMessageData(:final title, :final url):
        _handleSubSharing(sharer: message.sender, title: title, url: url);
      case ResetMessageData():
        if (mounted) Navigator.of(context).pop();
      case WhoAreYouMessageData():
        _rejoinIfConnected();
      default:
        {}
    }
  }

  void _handleProjection(
    User sender,
    VideoRecord videoRecord,
    Duration start,
  ) async {
    final currentRecord = context.read<PlayPayload?>()?.record;

    if (!sender.isCurrent(context) && !sender.isServer) {
      context.read<SyncMessageEvent>().fire('${sender.name} 分享了视频');
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

  void _updatePendingIds(List<String> ids) {
    _watchersPendingIdsNotifier.value = ids;
  }

  void _handleChannelStatus(
    User sender,
    ChannelPlayStatus channelPlayStatus,
    Duration position,
  ) async {
    // do not sync channel status when seeking
    if (_isChannelSeeking.value) return;

    final player = MediaPlayer.i;
    // Not loaded yet
    if (player.durationNotifier.value == Duration.zero) return;

    final localPosition = player.positionNotifier.value;

    if (!channelPlayStatus.isPlaying) {
      await player.pause();

      if (localPosition.near(
        position,
        tolerance: _Tolerances.silenceCatchUp.duration,
      )) {
        return;
      } else {
        await player.seek(position);
      }
    } else {
      if (localPosition.near(
        position,
        tolerance: _Tolerances.treatAsSync.duration,
      )) {
        player.rateNotifier.value = 1.0;
        _playbackOverlay.show(.playing);
        await player.play();
      } else if (localPosition.near(
        position,
        tolerance: _Tolerances.silenceCatchUp.duration,
      )) {
        player.rateNotifier.value = localPosition > position ? 0.95 : 1.05;
        _playbackOverlay.show(.playing);
        await player.play();
      } else if (localPosition > position &&
          localPosition - position < _Tolerances.waitForOthers.duration) {
        await player.pause();
      } else {
        _playbackOverlay.show(.playing);
        await player.play();
        await player.seek(position);
      }
    }
  }

  void _handleSubSharing({
    required User sharer,
    required String title,
    required String url,
  }) {
    context.read<SyncMessageEvent>().fire('${sharer.name} 分享了字幕');
    _channelSubtitleNotifier.value = (title: title, url: url, sharer: sharer);
  }

  void _startSlideSeeking() {
    _resetSlideSeekingTimer?.cancel();
    _isSlideSeeking = true;
  }

  void _endSlideSeeking() {
    _resetSlideSeekingTimer = Timer(1.seconds, () => _isSlideSeeking = false);
  }

  void _sendPendingStatus() {
    // Don't wait me when I'm sliding the progress bar
    if (_isSlideSeeking) {
      context.sendMessage(ClientStatusMessageData(isPending: false));
    } else {
      final duration = MediaPlayer.i.durationNotifier.value;
      final isLoaded = duration > Duration.zero;

      final position = MediaPlayer.i.positionNotifier.value;
      final almostFinished = duration - position < 1.seconds;

      final buffer = MediaPlayer.i.bufferNotifier.value;
      final bufferLow = (buffer - position) < Duration(seconds: 1);

      final isReady = almostFinished || isLoaded && !bufferLow;
      final data = ClientStatusMessageData(isPending: !isReady);
      context.sendMessage(data);
    }

    _statusSyncTimer.reset();
  }

  void _sendFinishMessage() {
    context.sendMessage(PlayFinishedMessageData());
  }

  void _rejoinIfConnected() {
    if (_chatClient.isConnectedNotifier.value) {
      context.sendMessage(JoinInMessageData(user: User.of(context)));
    }
  }
}

extension WrapPlaySyncBusiness on Widget {
  Widget playSyncBusiness({Key? key}) =>
      PlaySyncBusiness(key: key, child: this);
}
