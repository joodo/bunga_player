import 'dart:async';

import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/play/actions.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/chat/models/channel_data.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/video_entries/video_entry.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/play/providers.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/utils/models/network_progress.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

import 'models.dart';
import 'providers.dart';

class PositionAskingBusiness {
  String? askingMessageId;
}

class AskPositionIntent extends Intent {
  const AskPositionIntent();
}

class AskPositionAction extends ContextAction<AskPositionIntent> {
  final PositionAskingBusiness positionAskingBusiness;
  AskPositionAction({required this.positionAskingBusiness});

  @override
  Future<void> invoke(AskPositionIntent intent, [BuildContext? context]) async {
    final message = await (Actions.invoke(
      context!,
      SendMessageIntent(WhereAskingMessageData().toMessageData()),
    ) as Future<Message>);
    positionAskingBusiness.askingMessageId = message.id;

    Future.delayed(const Duration(seconds: 3), () {
      if (positionAskingBusiness.askingMessageId != null) {
        logger.w('Asked position but no one answered');
        positionAskingBusiness.askingMessageId = null;
      }
    });
  }
}

class ApplyRemotePlayingStatusIntent extends Intent {
  final User sender;
  final PlayStatusMessageData data;

  const ApplyRemotePlayingStatusIntent({
    required this.sender,
    required this.data,
  });
}

class ApplyRemotePlayingStatusAction
    extends ContextAction<ApplyRemotePlayingStatusIntent> {
  final PositionAskingBusiness positionAskingBusiness;
  ApplyRemotePlayingStatusAction({required this.positionAskingBusiness});

  @override
  FutureOr<void> invoke(
    ApplyRemotePlayingStatusIntent intent, [
    BuildContext? context,
  ]) async {
    final read = context!.read;

    positionAskingBusiness.askingMessageId = null;

    bool canShowToast = true;
    // If apply status is because asking where, then don't show snack bar
    if (intent.data.answerId != null) canShowToast = false;

    final isPlaying = read<PlayStatus>().isPlaying;
    if (intent.data.status == PlayStatusType.pause && isPlaying) {
      getIt<PlayService>().pause();
      if (canShowToast) {
        getIt<Toast>().show('${intent.sender.name} 暂停了视频');
        canShowToast = false;
        context.read<JustToggleByRemote>().mark();
      }
    }
    if (intent.data.status == PlayStatusType.play && !isPlaying) {
      getIt<PlayService>().play();
      if (canShowToast) {
        getIt<Toast>().show('${intent.sender.name} 播放了视频');
        canShowToast = false;
        context.read<JustToggleByRemote>().mark();
      }
    }

    final position = read<PlayPosition>().value;
    final remotePosition = intent.data.position;
    if (isPlaying && !position.near(remotePosition) ||
        position != remotePosition) {
      getIt<PlayService>().seek(remotePosition);
      if (canShowToast) {
        getIt<Toast>().show('${intent.sender.name} 调整了进度');
        canShowToast = false;
      }
    }
  }
}

class SendPlayingStatusIntent extends Intent {
  final PlayStatusType playingStatus;
  final Duration position;
  final String? answeringMessageId;

  const SendPlayingStatusIntent(
    this.playingStatus,
    this.position, {
    this.answeringMessageId,
  });
}

class SendPlayingStatusAction extends ContextAction<SendPlayingStatusIntent> {
  final PositionAskingBusiness positionAskingBusiness;

  SendPlayingStatusAction({required this.positionAskingBusiness});

  @override
  Future<void> invoke(SendPlayingStatusIntent intent, [BuildContext? context]) {
    return Actions.invoke(
        context!,
        SendMessageIntent(
          PlayStatusMessageData(
            status: intent.playingStatus,
            position: intent.position,
            answerId: intent.answeringMessageId,
          ).toMessageData(),
        )) as Future<void>;
  }

  @override
  bool isEnabled(SendPlayingStatusIntent intent, [BuildContext? context]) {
    assert(context != null);

    // I'm not playing the same video
    if (!context!.isVideoSameWithChannel) return false;

    // If answering someone's "where"
    if (intent.answeringMessageId != null) {
      // I'm asking too
      if (positionAskingBusiness.askingMessageId != null) return false;

      // I'm not even played
      final progress = context.read<PlayVideoSessions>().current?.progress;
      if (progress == null) return false;
    }

    return true;
  }
}

class ShareSubtitleIntent extends Intent {
  final String path;
  const ShareSubtitleIntent(this.path);
}

class FetchChannelSubtitleIntent extends Intent {
  final ChannelSubtitle channelSubtitle;
  const FetchChannelSubtitleIntent(this.channelSubtitle);
}

class FetchChannelSubtitleAction
    extends ContextAction<FetchChannelSubtitleIntent> {
  @override
  Future<void> invoke(FetchChannelSubtitleIntent intent,
      [BuildContext? context]) async {
    final currentSession = context!.read<PlayVideoSessions>().currentOrCreate();
    final track = await getIt<PlayService>()
        .loadSubtitleTrack(intent.channelSubtitle.url);
    currentSession.subtitleUri = track.uri;
    intent.channelSubtitle.track = track;
  }
}

class PlaySyncActions extends SingleChildStatefulWidget {
  const PlaySyncActions({super.key, super.child});

  @override
  State<PlaySyncActions> createState() => _PlaySyncActionsState();
}

class _PlaySyncActionsState extends SingleChildState<PlaySyncActions> {
  final _positionAskingBusiness = PositionAskingBusiness();

  late final _channelData = context.read<ChatChannelData>();
  late final _channelMessage = context.read<ChatChannelLastMessage>();

  @override
  void initState() {
    /*
    _channel.addListener(_askWhere);
    _channelData.addListener(_tryToFollowRemoteVideo);
    _channelMessage.addListener(_answerWhereAsking);
    _channelMessage.addListener(_applyRemotePlayingStatus);
    */
    super.initState();
  }

  @override
  void dispose() {
    _channelData.removeListener(_tryToFollowRemoteVideo);
    _channelMessage.removeListener(_answerWhereAsking);
    _channelData.removeListener(_applyRemotePlayingStatus);
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      actions: <Type, Action<Intent>>{},
      child: child!,
    );
  }

  void _tryToFollowRemoteVideo() {}

  void _applyRemotePlayingStatus() {
    final read = context.read;

    final message = read<ChatChannelLastMessage>().value;
    if (message == null || !message.data.isPlayStatus) return;

/* TODO::
    context.read<ActionsLeaf>().mayBeInvoke(
          ApplyRemotePlayingStatusIntent(
            sender: message.sender,
            data: message.data.toPlayStatus(),
          ),
        );
        */
  }

  void _askWhere() {
    context.read<ActionsLeaf>().mayBeInvoke(const AskPositionIntent());
  }

  void _answerWhereAsking() {
    final read = context.read;

    final message = read<ChatChannelLastMessage>().value;
    if (message == null || !message.data.isWhereAsking) return;
/* TODO::
    context.read<ActionsLeaf>().mayBeInvoke(
          SendPlayingStatusIntent(
            read<PlayStatus>().value,
            read<PlayPosition>().value,
            answeringMessageId: message.id,
          ),
        );*/
  }
}
