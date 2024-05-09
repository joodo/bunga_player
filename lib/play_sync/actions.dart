import 'dart:async';

import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/chat/models/channel_data.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/player/models/video_entries/video_entry.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/player/providers.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/player/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
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

class AskPositionIntent extends Intent {}

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

  @override
  bool isEnabled(AskPositionIntent intent, [BuildContext? context]) {
    final read = context!.read;
    return read<ChatUser>().value != null &&
        read<ChatChannel>().value != null &&
        read<ChatChannelWatchers>().value.length > 1;
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
      getIt<Player>().pause();
      if (canShowToast) {
        getIt<Toast>().show('${intent.sender.name} 暂停了视频');
        canShowToast = false;
        context.read<JustToggleByRemote>().mark();
      }
    }
    if (intent.data.status == PlayStatusType.play && !isPlaying) {
      getIt<Player>().play();
      if (canShowToast) {
        getIt<Toast>().show('${intent.sender.name} 播放了视频');
        canShowToast = false;
        context.read<JustToggleByRemote>().mark();
      }
    }

    final position = read<PlayPosition>().value;
    final remotePosition = intent.data.position;
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
        intent.data.answerId == positionAskingBusiness.askingMessageId;
    final isFromMe = intent.sender.id == context!.read<ChatUser>().value?.id;
    return isAnsweringMe && !isFromMe && context.isVideoSameWithChannel;
  }
}

class SendPlayingStatusIntent extends Intent {
  final PlayStatusType playingStatus;
  final Duration position;
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
    return Actions.invoke(
        context!,
        SendMessageIntent(
          PlayStatusMessageData(
            status: intent.playingStatus,
            position: intent.position,
            answerId: intent.answerId,
          ).toMessageData(),
        )) as Future<void>;
  }

  @override
  bool isEnabled(SendPlayingStatusIntent intent, [BuildContext? context]) {
    assert(context != null);
    final notAsking = positionAskingBusiness.askingMessageId == null;
    final notMyQuestion = positionAskingBusiness.askingMessageId !=
        context!.read<ChatUser>().value!.id;
    return notAsking && notMyQuestion && context.isVideoSameWithChannel;
  }
}

class ShareSubtitleIntent extends Intent {
  final String path;
  const ShareSubtitleIntent(this.path);
}

class ShareSubtitleAction extends ContextAction<ShareSubtitleIntent> {
  @override
  Stream<RequestProgress> invoke(ShareSubtitleIntent intent,
      [BuildContext? context]) async* {
    final title = path.basenameWithoutExtension(intent.path);
    yield* context!.read<ChatChannel>().value!.uploadFile(
          intent.path,
          description: 'subtitle $title',
        );
    getIt<Toast>().show('分享成功');
  }

  @override
  bool isEnabled(ShareSubtitleIntent intent, [BuildContext? context]) {
    return context?.read<ChatChannel>().value != null;
  }
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
    final track =
        await getIt<Player>().loadSubtitleTrack(intent.channelSubtitle.url);
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
        ShareSubtitleIntent: ShareSubtitleAction(),
        FetchChannelSubtitleIntent: FetchChannelSubtitleAction(),
      },
      child: child!,
    );
  }

  void _tryToFollowRemoteVideo() {
    final read = context.read;
    final currentUser = read<ChatUser>().value;
    final currentEntry = read<PlayVideoEntry>().value;
    final newChannelData = read<ChatChannelData>().value;

    // Leave channel
    if (newChannelData == null) return;

    // I did this
    if (currentUser?.id == newChannelData.sharer.id) return;

    // Not changing video
    if (currentEntry!.hash == newChannelData.videoHash) return;

    getIt<Toast>().show('${newChannelData.sharer.name} 更换了影片');

    // Only follow online video
    if (newChannelData.videoType != VideoType.online) return;

    final videoEntry = VideoEntry.fromChannelData(newChannelData);
    context
        .read<ActionsLeaf>()
        .mayBeInvoke(OpenVideoIntent(videoEntry: videoEntry));
  }

  void _dealChannelMessage() {
    final read = context.read;

    final message = read<ChatChannelLastMessage>().value;
    if (message == null) return;

    if (message.data.isWhereAsking) {
      context.read<ActionsLeaf>().mayBeInvoke(
            SendPlayingStatusIntent(
              read<PlayStatus>().value,
              read<PlayPosition>().value,
              answerId: message.id,
            ),
          );
    } else if (message.data.isPlayStatus) {
      context.read<ActionsLeaf>().mayBeInvoke(
            ApplyRemotePlayingStatusIntent(
              sender: message.sender,
              data: message.data.toPlayStatus(),
            ),
          );
    }
  }
}
