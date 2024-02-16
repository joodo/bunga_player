import 'dart:async';

import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/wrappers/providers.dart';
import 'package:bunga_player/screens/wrappers/shortcuts.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/player.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OpenVideoIntent extends Intent {
  final VideoEntry videoEntry;
  final Future<void>? Function()? beforeAskingPosition;
  final bool askPosition;

  const OpenVideoIntent({
    required this.videoEntry,
    this.beforeAskingPosition,
    this.askPosition = true,
  });
}

class PositionAskingBusiness {
  String? askingMessageId;
}

class OpenVideoAction extends ContextAction<OpenVideoIntent> {
  final PositionAskingBusiness positionAskingBusiness;
  OpenVideoAction({required this.positionAskingBusiness});

  @override
  Future<void> invoke(OpenVideoIntent intent, [BuildContext? context]) async {
    assert(context != null);

    final bi = context!.read<BusinessIndicator>();
    final videoPlayer = getIt<Player>();

    await bi.run(
      tasks: [
        bi.setTitle('正在鬼鬼祟祟……'),
        (data) async {
          await videoPlayer.stop();
          await intent.videoEntry.fetch();
        },
        bi.setTitle('正在收拾客厅……'),
        (data) => videoPlayer.open(intent.videoEntry),
        bi.setTitle('正在发送请柬……'),
        (data) async {
          await intent.beforeAskingPosition?.call();
          if (intent.askPosition && context.mounted) {
            await _askPosition(context);
          }
        },
      ],
    );
  }

  Future<void> _askPosition(BuildContext context) async {
    final message = await (Actions.invoke(
      context,
      const SendMessageIntent('where'),
    ) as Future<Message>);
    positionAskingBusiness.askingMessageId = message.id;

    Future.delayed(const Duration(seconds: 6), () {
      if (positionAskingBusiness.askingMessageId != null) {
        logger.w('Asked position but no one answered');
        positionAskingBusiness.askingMessageId = null;
      }
    });
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
    final isFromMe = intent.sender.id == context!.read<CurrentUser>().value!.id;
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

class VideoPlayingActions extends StatefulWidget {
  final Widget child;
  const VideoPlayingActions({super.key, required this.child});

  @override
  State<VideoPlayingActions> createState() => _VideoPlayingActionsState();
}

class _VideoPlayingActionsState extends State<VideoPlayingActions> {
  final _positionAskingBusiness = PositionAskingBusiness();

  @override
  void initState() {
    context.read<CurrentChannelData>().addListener(_tryToFollowRemoteVideo);
    context.read<CurrentChannelMessage>().addListener(_dealChannelMessage);
    super.initState();
  }

  @override
  void dispose() {
    context.read<CurrentChannelData>().removeListener(_tryToFollowRemoteVideo);
    context.read<CurrentChannelMessage>().removeListener(_dealChannelMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'Video Playing'),
      actions: <Type, Action<Intent>>{
        OpenVideoIntent: OpenVideoAction(
          positionAskingBusiness: _positionAskingBusiness,
        ),
        ApplyRemotePlayingStatusIntent: ApplyRemotePlayingStatusAction(
          positionAskingBusiness: _positionAskingBusiness,
        ),
        SendPlayingStatusIntent: SendPlayingStatusAction(
          positionAskingBusiness: _positionAskingBusiness,
        ),
      },
      child: widget.child,
    );
  }

  void _tryToFollowRemoteVideo() {
    final read = Intentor.context.read;
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
    Actions.invoke(
      Intentor.context,
      OpenVideoIntent(videoEntry: videoEntry),
    );
  }

  void _dealChannelMessage() {
    final read = Intentor.context.read;

    final message = read<CurrentChannelMessage>().value!;
    final splits = message.text.split(' ');
    switch (splits.first) {
      case 'pause':
      case 'play':
        Actions.maybeInvoke(
          Intentor.context,
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
        Actions.maybeInvoke(
          Intentor.context,
          SendPlayingStatusIntent(
            read<PlayStatus>().value,
            read<PlayPosition>().value.inMilliseconds,
            answerId: message.id,
          ),
        );
    }
  }
}
