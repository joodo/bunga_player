import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/actions/voice_call.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class SubscriptionBusiness {
  final subscriptions = <StreamSubscription>[];
  final BuildContext actionContext;
  int joinChannelTimestamp = 0;

  SubscriptionBusiness({required this.actionContext});
}

class JoinChannelIntent extends Intent {
  final ChannelData? channelData;
  final String? channelId;
  const JoinChannelIntent.byChannelData(this.channelData) : channelId = null;
  const JoinChannelIntent.byId(this.channelId) : channelData = null;
}

class JoinChannelAction extends ContextAction<JoinChannelIntent> {
  final SubscriptionBusiness subscriptionBusiness;

  JoinChannelAction({required this.subscriptionBusiness});

  @override
  Future<void>? invoke(
    JoinChannelIntent intent, [
    BuildContext? context,
  ]) async {
    assert(context != null, 'Action need context to set providers');

    final chatService = getIt<ChatService>();
    final response = intent.channelData != null
        ? await chatService.createOrJoinChannelByData(intent.channelData!)
        : await chatService.joinChannelById(intent.channelId!);

    if (!context!.mounted) {
      logger.w('Context of joining channel was unmounted.');
      return;
    }

    subscriptionBusiness.joinChannelTimestamp =
        DateTime.now().millisecondsSinceEpoch;
    final actionRead = subscriptionBusiness.actionContext.read;
    subscriptionBusiness.subscriptions.addAll([
      response.streams.channelData.listen((channelData) {
        final current = actionRead<CurrentChannelData>();
        current.value = channelData;
        logger.i('Channel: Data changed: $channelData');
      }),
      response.streams.joiner.listen((user) {
        actionRead<CurrentChannelWatchers>().join(user);
        logger.i('Channel: User join channel: $user');
      }),
      response.streams.leaver.listen((user) {
        actionRead<CurrentChannelWatchers>().leave(user);
        logger.i('Channel: User leave channel: $user');
      }),
      response.streams.message.listen((message) {
        actionRead<CurrentChannelMessage>().value = message;
        logger.i('Channel: Message received: $message');
      }),
      response.streams.file.listen((channelFile) {
        final files = actionRead<CurrentChannelFiles>();
        files.value = [...files.value, channelFile];
        logger.i('Channel: New file: $channelFile');
      }),
    ]);

    final read = context.read;
    read<CurrentChannelId>().value = response.id;
  }
}

class LeaveChannelIntent extends Intent {}

class LeaveChannelAction extends ContextAction<LeaveChannelIntent> {
  final SubscriptionBusiness subscriptionBusiness;
  LeaveChannelAction({required this.subscriptionBusiness});

  @override
  Future<void>? invoke(
    LeaveChannelIntent intent, [
    BuildContext? context,
  ]) async {
    final read = context!.read;

    Actions.maybeInvoke(context, HangUpIntent());

    for (final subscription in subscriptionBusiness.subscriptions) {
      await subscription.cancel();
    }
    subscriptionBusiness.subscriptions.clear();

    read<CurrentChannelId>().value = null;
    read<CurrentChannelData>().value = null;
    read<CurrentChannelMessage>().value = null;
    read<CurrentChannelWatchers>().clear();
    read<CurrentChannelFiles>().value = [];

    final chatService = getIt<ChatService>();
    await chatService.leaveChannel();
  }

  @override
  bool isEnabled(LeaveChannelIntent intent, [BuildContext? context]) {
    return context?.read<CurrentChannelId>().value != null;
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

class SendMessageAction extends ContextAction<SendMessageIntent> {
  @override
  Future<Message> invoke(SendMessageIntent intent,
      [BuildContext? context]) async {
    final chatService = getIt<ChatService>();
    logger.i('Send message: ${intent.text}, quote id: ${intent.quoteId}');
    return await chatService.sendMessage(intent.text, quoteId: intent.quoteId);
  }

  @override
  bool isEnabled(SendMessageIntent intent, [BuildContext? context]) {
    return context?.read<CurrentChannelId>().value != null;
  }
}

class ChannelActions extends SingleChildStatefulWidget {
  const ChannelActions({super.key, super.child});
  @override
  State<ChannelActions> createState() => _ChannelActionsState();
}

class _ChannelActionsState extends SingleChildState<ChannelActions> {
  late final _subscriptionBusiness =
      SubscriptionBusiness(actionContext: context);

  late final _currentWatchers = context.read<CurrentChannelWatchers>();

  @override
  void initState() {
    _currentWatchers.addJoinListener(_onUserJoin);
    _currentWatchers.addLeaveListener(_onUserLeave);

    super.initState();
  }

  @override
  void dispose() {
    _currentWatchers.removeJoinListener(_onUserJoin);
    _currentWatchers.removeLeaveListener(_onUserLeave);

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'Channel'),
      actions: <Type, Action<Intent>>{
        JoinChannelIntent:
            JoinChannelAction(subscriptionBusiness: _subscriptionBusiness),
        LeaveChannelIntent:
            LeaveChannelAction(subscriptionBusiness: _subscriptionBusiness),
        UpdateChannelDataIntent: UpdateChannelDataAction(),
        SendMessageIntent: SendMessageAction(),
      },
      child: child!,
    );
  }

  void _onUserJoin(User user) {
    final currentId = context.read<CurrentUser>().value!.id;
    if (user.id == currentId) return;

    // Mute when pulling exist channel watchers
    if (DateTime.now().millisecondsSinceEpoch -
            _subscriptionBusiness.joinChannelTimestamp <
        2000) return;
    getIt<Toast>().show('${user.name} 已加入');
    AudioPlayer().play(AssetSource('sounds/user_join.wav'));
  }

  void _onUserLeave(User user) {
    getIt<Toast>().show('${user.name} 已离开');
    AudioPlayer().play(AssetSource('sounds/user_leave.wav'));
  }
}
