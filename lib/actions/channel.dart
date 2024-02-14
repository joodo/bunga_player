import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/screens/wrappers/shortcuts.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinChannelIntent extends Intent {
  final ChannelData? channelData;
  final String? channelId;
  const JoinChannelIntent.byChannelData(this.channelData) : channelId = null;
  const JoinChannelIntent.byId(this.channelId) : channelData = null;
}

class JoinChannelAction extends ContextAction<JoinChannelIntent> {
  final List<StreamSubscription> channelSubscriptions;

  JoinChannelAction({required this.channelSubscriptions});

  @override
  Future<void>? invoke(
    JoinChannelIntent intent, [
    BuildContext? context,
  ]) async {
    assert(context != null, 'Action need context to set providers');

    final read = context!.read;

    final chatService = getIt<ChatService>();
    final response = intent.channelData != null
        ? chatService.createOrJoinChannelByData(intent.channelData!)
        : chatService.joinChannelById(intent.channelId!);
    final (
      id,
      watchers,
      dataStream,
      joinerStream,
      leaverStream,
      messageStream,
    ) = await response;

    channelSubscriptions.addAll([
      dataStream.listen((channelData) {
        final current = Intentor.context.read<CurrentChannelData>();
        // HACK: stream io sdk trigger bugly even when changed nothing,
        //  cause annoying logs
        if (current.value == channelData) return;

        current.value = channelData;
        logger.i('Channel data changed: $channelData');
      }),
      joinerStream.listen((user) {
        Intentor.context.read<CurrentChannelWatchers>().join(user);
        logger.i('User join channel: $user');
      }),
      leaverStream.listen((user) {
        Intentor.context.read<CurrentChannelWatchers>().leave(user);
        logger.i('User leave channel: $user');
      }),
      messageStream.listen((message) {
        Intentor.context.read<CurrentChannelMessage>().value = message;
        logger.i('Message received: $message');
      }),
    ]);

    read<CurrentChannelId>().value = id;
    read<CurrentChannelWatchers>().set(watchers);
  }
}

class LeaveChannelIntent extends Intent {}

class LeaveChannelAction extends ContextAction<LeaveChannelIntent> {
  final List<StreamSubscription> channelSubscriptions;
  LeaveChannelAction({required this.channelSubscriptions});

  @override
  Future<void>? invoke(
    LeaveChannelIntent intent, [
    BuildContext? context,
  ]) async {
    final read = context!.read;

    for (final subscription in channelSubscriptions) {
      await subscription.cancel();
    }
    channelSubscriptions.clear();

    final chatService = getIt<ChatService>();
    await chatService.leaveChannel();

    read<CurrentChannelId>().value = null;
    read<CurrentChannelData>().value = null;
    read<CurrentChannelWatchers>().clear();
  }
}

class UpdateChannelDataIntent extends Intent {
  final ChannelData channelData;
  const UpdateChannelDataIntent(this.channelData);
}

class UpdateChannelDataAction extends Action<UpdateChannelDataIntent> {
  @override
  Future<void>? invoke(UpdateChannelDataIntent intent) {
    final chatService = getIt<ChatService>();
    return chatService.updateChannelData(intent.channelData);
  }
}

class SendMessageIntent extends Intent {
  final String text;
  final String? quoteId;

  const SendMessageIntent(this.text, {this.quoteId});
}

class SendMessageAction extends Action<SendMessageIntent> {
  @override
  Future<Message> invoke(SendMessageIntent intent) async {
    final chatService = getIt<ChatService>();
    logger.i('Send message: ${intent.text}, quote id: ${intent.quoteId}');
    return await chatService.sendMessage(intent.text, intent.quoteId);
  }
}

class ChannelActions extends StatefulWidget {
  final Widget child;
  const ChannelActions({super.key, required this.child});
  @override
  State<ChannelActions> createState() => _ChannelActionsState();
}

class _ChannelActionsState extends State<ChannelActions> {
  final List<StreamSubscription> _channelSubscriptions = [];

  @override
  void initState() {
    final currentWatchers = context.read<CurrentChannelWatchers>();
    currentWatchers.addJoinListener(_onUserJoin);
    currentWatchers.addLeaveListener(_onUserLeave);

    super.initState();
  }

  @override
  void dispose() {
    final currentWatchers = context.read<CurrentChannelWatchers>();
    currentWatchers.removeJoinListener(_onUserJoin);
    currentWatchers.removeLeaveListener(_onUserLeave);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'Channel'),
      actions: <Type, Action<Intent>>{
        JoinChannelIntent:
            JoinChannelAction(channelSubscriptions: _channelSubscriptions),
        LeaveChannelIntent:
            LeaveChannelAction(channelSubscriptions: _channelSubscriptions),
        UpdateChannelDataIntent: UpdateChannelDataAction(),
        SendMessageIntent: SendMessageAction(),
      },
      child: widget.child,
    );
  }

  void _onUserJoin(User user) {
    final currentId = context.read<CurrentUser>().value!.id;
    if (user.id == currentId) return;

    getIt<Toast>().show('${user.name} 已加入');
    AudioPlayer().play(AssetSource('sounds/user_join.wav'));
  }

  void _onUserLeave(User user) {
    getIt<Toast>().show('${user.name} 已离开');
    AudioPlayer().play(AssetSource('sounds/user_leave.wav'));
  }
}
