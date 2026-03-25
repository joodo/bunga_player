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
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/play/play.dart';
import 'package:bunga_player/screens/dialogs/open_video/gallery.dart';
import 'package:bunga_player/screens/dialogs/video_conflict.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';

import 'providers.dart';

class BusinessPayload {
  // Toggle
  final remoteJustToggledNotifier = AutoResetNotifier(
    const Duration(seconds: 1),
  );

  // Seeking
  final isChannelSeeking = AutoResetNotifier(5.seconds);
  bool isSlideSeeking = false;
  Timer? resetSlideSeekingTimer;

  void dispose() {
    remoteJustToggledNotifier.dispose();
    isChannelSeeking.dispose();
    resetSlideSeekingTimer?.cancel();
  }
}

class PlaySyncBusiness extends SingleChildStatefulWidget {
  const PlaySyncBusiness({
    super.key,
    super.child,
    required this.business,
    required this.pendingWatcherIdsNotifier,
    required this.channelSubtitleNotifier,
  });

  final BusinessPayload business;

  final ValueNotifier<PendingWatcherIds> pendingWatcherIdsNotifier;
  final ValueNotifier<ChannelSubtitle?> channelSubtitleNotifier;

  @override
  State<PlaySyncBusiness> createState() => _PlaySyncBusinessState();
}

class _PlaySyncBusinessState extends SingleChildState<PlaySyncBusiness> {
  // Chat
  late final _chatClient = context.read<ChatClient>();
  late final StreamSubscription _streamSubscription;

  // My status
  static const _statusSendInterval = Duration(seconds: 1);
  late final _statusSyncTimer = RestartableTimer(
    _statusSendInterval,
    _sendPendingStatus,
  );

  // Subtitle sharing

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

    _streamSubscription.cancel();

    _statusSyncTimer.cancel();

    _chatClient.isConnectedNotifier.removeListener(_rejoinIfConnected);

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child!;
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

        final manager = read<PlayMessageEvent>();
        final name = message.sender.name;
        manager.fire('$name 播放了视频');
        read<PlayToggleVisualSignal>().fire(true);

        widget.business.remoteJustToggledNotifier.mark();
      case PauseMessageData(:final position):
        if (message.sender.isCurrent(context)) break;

        // Paused by user, not by waiting pending
        // So pause immediately and seek, do not wait for channel status message
        MediaPlayer.i.pause();
        if (position != null &&
            !_SyncChecker.isSync(MediaPlayer.i.position, position)) {
          logger.i('Seek: $position, reason: handle PauseMessageData');
          MediaPlayer.i.seek(position);
        }

        final manager = read<PlayMessageEvent>();
        final name = message.sender.name;
        manager.fire('$name 暂停了视频');
        read<PlayToggleVisualSignal>().fire(false);

        widget.business.remoteJustToggledNotifier.mark();
      case SeekMessageData(:final position):
        if (message.sender.isCurrent(context)) break;

        final manager = read<PlayMessageEvent>();
        final name = message.sender.name;
        manager.fire('$name 调整了进度');

        // Seek immediately, do not wait for channel status message
        logger.i('Seek: $position, reason: handle SeekMessageData');
        MediaPlayer.i.seek(position);

        widget.business.isChannelSeeking.mark();
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
      context.read<PlayMessageEvent>().fire('${sender.name} 分享了视频');
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
    widget.pendingWatcherIdsNotifier.value = PendingWatcherIds(ids);
  }

  void _handleChannelStatus(
    User sender,
    ChannelPlayStatus channelPlayStatus,
    Duration position,
  ) async {
    // do not sync channel status when seeking
    if (widget.business.isChannelSeeking.value) return;
    // do not sync channel when I'm slide seeking
    if (widget.business.isSlideSeeking) return;

    final player = MediaPlayer.i;
    // Not loaded yet
    if (player.duration == Duration.zero) return;

    if (!channelPlayStatus.isPlaying) {
      await player.pause();

      if (!_SyncChecker.isNear(player.position, position)) {
        logger.i('Seek: $position, reason: handle ChannelStatus, when paused');
        await player.seek(position);
      }
    } else {
      if (_SyncChecker.isSync(player.position, position)) {
        player.rateNotifier.value = 1.0;
        await player.play();
      } else if (_SyncChecker.isNear(player.position, position)) {
        player.rateNotifier.value = player.position > position ? 0.95 : 1.05;
        await player.play();
      } else if (_SyncChecker.couldWait(player.position, position)) {
        await player.pause();
      } else {
        logger.i('Seek: $position, reason: handle ChannelStatus, when playing');
        await player.seek(position);
        await player.play();
      }
    }
  }

  void _handleSubSharing({
    required User sharer,
    required String title,
    required String url,
  }) {
    context.read<PlayMessageEvent>().fire('${sharer.name} 分享了字幕');
    widget.channelSubtitleNotifier.value = (
      title: title,
      url: url,
      sharer: sharer,
    );
  }

  void _sendPendingStatus() {
    // Don't wait me when I'm sliding the progress bar
    if (widget.business.isSlideSeeking) {
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
  Widget playSyncBusiness({
    required final ValueNotifier<PendingWatcherIds> pendingWatcherIdsNotifier,
    required final ValueNotifier<ChannelSubtitle?> channelSubtitleNotifier,
    required BusinessPayload business,
  }) => PlaySyncBusiness(
    pendingWatcherIdsNotifier: pendingWatcherIdsNotifier,
    channelSubtitleNotifier: channelSubtitleNotifier,
    business: business,
    child: this,
  );
}

class _SyncChecker {
  static const treatAsSyncTolerance = Duration(milliseconds: 400);
  static const silenceCatchUpTolerance = Duration(seconds: 3);
  static const waitForOthersTolerance = Duration(seconds: 7);

  static bool isSync(Duration local, Duration remote) =>
      local.near(remote, tolerance: treatAsSyncTolerance);
  static bool isNear(Duration local, Duration remote) =>
      local.near(remote, tolerance: silenceCatchUpTolerance);
  static bool couldWait(Duration local, Duration remote) =>
      local > remote && local - remote < waitForOthersTolerance;
}
