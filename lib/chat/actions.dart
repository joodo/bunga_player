import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/voice_call/actions.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'models/channel_data.dart';
import 'models/message.dart';
import 'models/user.dart';
import 'providers.dart';

class SubscriptionBusiness {
  final subscriptions = <StreamSubscription>[];
  final BuildContext actionContext;
  int joinChannelTimestamp = 0;

  SubscriptionBusiness({required this.actionContext});
}

class UpdateChannelDataIntent extends Intent {
  final ChannelData channelData;
  const UpdateChannelDataIntent(this.channelData);
}

class UpdateChannelDataAction extends ContextAction<UpdateChannelDataIntent> {
  @override
  Future<void>? invoke(
    UpdateChannelDataIntent intent, [
    BuildContext? context,
  ]) {
    final channel = context!.read<ChatChannel>();
    return channel.value!.updateData(intent.channelData);
  }

  @override
  bool isEnabled(UpdateChannelDataIntent intent, [BuildContext? context]) {
    return context?.read<ChatChannel>().value != null;
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
    logger.i('Send message: ${intent.text}, quote id: ${intent.quoteId}');
    return context!
        .read<ChatChannel>()
        .value!
        .sendMessage(intent.text, quoteId: intent.quoteId);
  }

  @override
  bool isEnabled(SendMessageIntent intent, [BuildContext? context]) {
    return context?.read<ChatChannel>().value != null;
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

  late final _currentWatchers = context.read<ChatChannelWatchers>();
  late final _currentChannel = context.read<ChatChannel>();

  @override
  void initState() {
    _currentWatchers.addJoinListener(_onUserJoin);
    _currentWatchers.addLeaveListener(_onUserLeave);
    _currentChannel.addListener(_autoHangUp);

    super.initState();
  }

  @override
  void dispose() {
    _currentWatchers.removeJoinListener(_onUserJoin);
    _currentWatchers.removeLeaveListener(_onUserLeave);
    _currentChannel.removeListener(_autoHangUp);

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      actions: <Type, Action<Intent>>{
        UpdateChannelDataIntent: UpdateChannelDataAction(),
        SendMessageIntent: SendMessageAction(),
      },
      child: child!,
    );
  }

  void _onUserJoin(User user) {
    final currentId = context.read<ChatUser>().value!.id;
    if (user.id == currentId) return;

    // Mute when pulling exist channel watchers
    if (DateTime.now().millisecondsSinceEpoch -
            _subscriptionBusiness.joinChannelTimestamp <
        3000) return;
    getIt<Toast>().show('${user.name} 已加入');
    AudioPlayer().play(AssetSource('sounds/user_join.wav'));
  }

  void _onUserLeave(User user) {
    getIt<Toast>().show('${user.name} 已离开');
    AudioPlayer().play(AssetSource('sounds/user_leave.wav'));
  }

  void _autoHangUp() {
    if (_currentChannel.value == null) {
      context.read<ActionsLeaf>().maybeInvoke(HangUpIntent());
    }
  }
}
