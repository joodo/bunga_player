import 'dart:async';

import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/actions/wrapper.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/providers/wrapper.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/player.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class PositionAskingBusiness {
  String? askingMessageId;
}

class AskPositionIntent extends Intent {}

class AskPositionAction extends ContextAction<AskPositionIntent> {
  final PositionAskingBusiness positionAskingBusiness;
  AskPositionAction({required this.positionAskingBusiness});

  @override
  Future<void> invoke(AskPositionIntent intent, [BuildContext? context]) async {
    final message = await (Actions.invoke(
      context!,
      const SendMessageIntent('where'),
    ) as Future<Message>);
    positionAskingBusiness.askingMessageId = message.id;

    Future.delayed(const Duration(seconds: 3), () {
      if (positionAskingBusiness.askingMessageId != null) {
        logger.w('Asked position but no one answered');
        positionAskingBusiness.askingMessageId = null;
      }
    });
  }

  @override
  bool isEnabled(AskPositionIntent intent, [BuildContext? context]) {
    final read = context!.read;
    return read<CurrentUser>().value != null &&
        read<CurrentChannelId>().value != null &&
        read<CurrentChannelWatchers>().value.length > 1;
  }
}

class ApplyRemotePlayingStatusIntent extends Intent {
  final PlayStatusType status;
  final int position;
  final User sender;
  final String? answerId;

  const ApplyRemotePlayingStatusIntent(
    this.status,
    this.position,
    this.sender,
    this.answerId,
  );
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
    if (intent.answerId != null) canShowToast = false;

    final isPlaying = read<PlayStatus>().isPlaying;
    if (intent.status == PlayStatusType.pause && isPlaying) {
      getIt<Player>().pause();
      if (canShowToast) {
        getIt<Toast>().show('${intent.sender.name} 暂停了视频');
        canShowToast = false;
        context.read<JustToggleByRemote>().mark();
      }
    }
    if (intent.status == PlayStatusType.play && !isPlaying) {
      getIt<Player>().play();
      if (canShowToast) {
        getIt<Toast>().show('${intent.sender.name} 播放了视频');
        canShowToast = false;
        context.read<JustToggleByRemote>().mark();
      }
    }

    final position = read<PlayPosition>().value;
    final remotePosition = Duration(milliseconds: intent.position);
    if ((position - remotePosition).inMilliseconds.abs() > 1000) {
      getIt<Player>().seek(remotePosition);
      if (canShowToast) {
        getIt<Toast>().show('${intent.sender.name} 调整了进度');
        canShowToast = false;
      }
    }
  }

  @override
  bool isEnabled(
    ApplyRemotePlayingStatusIntent intent, [
    BuildContext? context,
  ]) {
    assert(context != null);

    // Answering me or just normal tell
    final isAnsweringMe =
        intent.answerId == positionAskingBusiness.askingMessageId;
    final isFromMe = intent.sender.id == context!.read<CurrentUser>().value?.id;
    return isAnsweringMe && !isFromMe && context.isVideoSameWithChannel;
  }
}

class SendPlayingStatusIntent extends Intent {
  final PlayStatusType playingStatus;
  final int position;
  final String? answerId;

  const SendPlayingStatusIntent(
    this.playingStatus,
    this.position, {
    this.answerId,
  });
}

class SendPlayingStatusAction extends ContextAction<SendPlayingStatusIntent> {
  final PositionAskingBusiness positionAskingBusiness;

  SendPlayingStatusAction({required this.positionAskingBusiness});

  @override
  Future<void> invoke(SendPlayingStatusIntent intent, [BuildContext? context]) {
    final messageText = '${intent.playingStatus.name} at ${intent.position}';

    return Actions.invoke(
        context!,
        SendMessageIntent(
          messageText,
          quoteId: intent.answerId,
        )) as Future<void>;
  }

  @override
  bool isEnabled(SendPlayingStatusIntent intent, [BuildContext? context]) {
    assert(context != null);
    final notAsking = positionAskingBusiness.askingMessageId == null;
    final notMyQuestion = positionAskingBusiness.askingMessageId !=
        context!.read<CurrentUser>().value!.id;
    return notAsking && notMyQuestion && context.isVideoSameWithChannel;
  }
}

class VideoPlayingActions extends SingleChildStatefulWidget {
  const VideoPlayingActions({super.key, super.child});

  @override
  State<VideoPlayingActions> createState() => _VideoPlayingActionsState();
}

class _VideoPlayingActionsState extends SingleChildState<VideoPlayingActions> {
  final _positionAskingBusiness = PositionAskingBusiness();

  late final _channelData = context.read<CurrentChannelData>();
  late final _channelMessage = context.read<CurrentChannelMessage>();

  @override
  void initState() {
    _channelData.addListener(_tryToFollowRemoteVideo);
    _channelMessage.addListener(_dealChannelMessage);
    super.initState();
  }

  @override
  void dispose() {
    _channelData.removeListener(_tryToFollowRemoteVideo);
    _channelData.removeListener(_dealChannelMessage);
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'Video Playing'),
      actions: <Type, Action<Intent>>{
        AskPositionIntent: AskPositionAction(
          positionAskingBusiness: _positionAskingBusiness,
        ),
        ApplyRemotePlayingStatusIntent: ApplyRemotePlayingStatusAction(
          positionAskingBusiness: _positionAskingBusiness,
        ),
        SendPlayingStatusIntent: SendPlayingStatusAction(
          positionAskingBusiness: _positionAskingBusiness,
        ),
      },
      child: child!,
    );
  }

  void _tryToFollowRemoteVideo() {
    final read = context.read;
    final currentUser = read<CurrentUser>();
    final currentChannelData = read<CurrentChannelData>();
    final currentData = currentChannelData.value;
    final oldData = currentChannelData.oldValue;

    // Leave channel
    if (currentData == null) return;

    // I did this
    if (currentUser.value?.id == currentData.sharer.id) return;

    // Just join channel, no need to toast and follow video
    if (oldData == null) return;

    // Not changing video
    if (oldData.videoHash == currentData.videoHash) return;

    getIt<Toast>().show('${currentData.sharer.name} 更换了影片');

    // Only follow online video
    if (currentChannelData.value!.videoType != VideoType.online) return;

    final videoEntry = VideoEntry.fromChannelData(currentData);
    context
        .read<ActionsLeaf>()
        .mayBeInvoke(OpenVideoIntent(videoEntry: videoEntry));
  }

  void _dealChannelMessage() {
    final read = context.read;

    final message = read<CurrentChannelMessage>().value;
    if (message == null) return;

    final splits = message.text.split(' ');
    switch (splits.first) {
      case 'pause':
      case 'play':
        context.read<ActionsLeaf>().mayBeInvoke(
              ApplyRemotePlayingStatusIntent(
                splits.first == 'pause'
                    ? PlayStatusType.pause
                    : PlayStatusType.play,
                int.parse(splits.last),
                message.sender,
                message.quoteId,
              ),
            );
      case 'where':
        context.read<ActionsLeaf>().mayBeInvoke(
              SendPlayingStatusIntent(
                read<PlayStatus>().value,
                read<PlayPosition>().value.inMilliseconds,
                answerId: message.id,
              ),
            );
    }
  }
}
