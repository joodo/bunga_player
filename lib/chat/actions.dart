import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/play_sync/models.dart';
import 'package:bunga_player/play_sync/providers.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/voice_call/providers.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'models/channel_data.dart';
import 'models/message_data.dart';
import 'models/message.dart';
import 'models/user.dart';
import 'providers.dart';

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

class JoinChannelIntent extends Intent {
  final ChannelJoinPayload payload;

  const JoinChannelIntent(this.payload);
}

class JoinChannelAction extends ContextAction<JoinChannelIntent> {
  @override
  Future<void> invoke(JoinChannelIntent intent, [BuildContext? context]) async {
    context!.read<ChatChannelJoinPayload>().value = intent.payload;
  }
}

class LeaveChannelIntent extends Intent {
  const LeaveChannelIntent();
}

class LeaveChannelAction extends ContextAction<LeaveChannelIntent> {
  @override
  Future<void> invoke(LeaveChannelIntent intent,
      [BuildContext? context]) async {
    final read = context!.read;

    final payloadNotifier = read<ChatChannelJoinPayload>();

    final response = read<ActionsLeaf>()
        .invoke(SendMessageIntent(ByeMessageData().toMessageData())) as Future;
    await response;

    payloadNotifier.value = null;
  }

  @override
  bool isEnabled(Intent intent, [BuildContext? context]) {
    return context!.read<ChatChannel>().value != null;
  }
}

class SendMessageIntent extends Intent {
  final Map<String, dynamic> data;

  const SendMessageIntent(this.data);
}

class SendMessageAction extends ContextAction<SendMessageIntent> {
  @override
  Future<Message> invoke(
    SendMessageIntent intent, [
    BuildContext? context,
  ]) async {
    final raw = await context!
        .read<ChatChannel>()
        .value!
        .sendMessage(jsonEncode(intent.data));
    return raw.toMessage();
  }

  @override
  bool isEnabled(SendMessageIntent intent, [BuildContext? context]) {
    return context?.read<ChatChannel>().value != null;
  }
}

class RefreshWatchersIntent extends Intent {
  const RefreshWatchersIntent();
}

class RefreshWatchersAction extends ContextAction<RefreshWatchersIntent> {
  @override
  Future<void> invoke(RefreshWatchersIntent intent, [BuildContext? context]) {
    final read = context!.read;

    read<ChatChannelWatchers>().clear();
    return read<ActionsLeaf>().invoke(SendMessageIntent(
      AlohaMessageData(
        user: read<ChatUser>().value!,
      ).toMessageData(),
    )) as Future;
  }

  @override
  bool isEnabled(RefreshWatchersIntent intent, [BuildContext? context]) {
    return context?.read<ChatChannel>().value != null;
  }
}

class ChatActions extends SingleChildStatefulWidget {
  const ChatActions({super.key, super.child});
  @override
  State<ChatActions> createState() => _ChannelActionsState();
}

class _ChannelActionsState extends SingleChildState<ChatActions> {
  late final _currentWatchers = context.read<ChatChannelWatchers>();
  late final _currentChannel = context.read<ChatChannel>();
  late final _lastMessage = context.read<ChatChannelLastMessage>();

  @override
  void initState() {
    _currentWatchers.addJoinListener(_notifyUserJoin);
    _currentWatchers.addLeaveListener(_notifyUserLeave);
    _currentChannel.addListener(_sendAloha);
    _lastMessage.addListener(_updateWatchers);
    _lastMessage.addListener(_answerAloha);

    getIt<ExitCallbacks>().add(() async {
      return context.read<ActionsLeaf>().maybeInvoke(
            const LeaveChannelIntent(),
          ) as Future?;
    });

    super.initState();
  }

  @override
  void dispose() {
    _currentWatchers.removeJoinListener(_notifyUserJoin);
    _currentWatchers.removeLeaveListener(_notifyUserLeave);
    _currentChannel.removeListener(_sendAloha);
    _lastMessage.removeListener(_updateWatchers);
    _lastMessage.removeListener(_answerAloha);

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      actions: <Type, Action<Intent>>{
        UpdateChannelDataIntent: UpdateChannelDataAction(),
        SendMessageIntent: SendMessageAction(),
        JoinChannelIntent: JoinChannelAction(),
        LeaveChannelIntent: LeaveChannelAction(),
        RefreshWatchersIntent: RefreshWatchersAction(),
      },
      child: child!,
    );
  }

  void _notifyUserJoin({required User user, required bool isNew}) {
    final currentId = context.read<ChatUser>().value!.id;
    if (user.id == currentId) return;

    if (!isNew) return;
    getIt<Toast>().show('${user.name} 已加入');
    AudioPlayer().play(AssetSource('sounds/user_join.wav'));
  }

  void _notifyUserLeave({required User user}) {
    getIt<Toast>().show('${user.name} 已离开');
    AudioPlayer().play(AssetSource('sounds/user_leave.wav'));
  }

  void _updateWatchers() {
    final message = _lastMessage.value;
    if (message == null) return;

    final isOther = message.sender.id != context.read<ChatUser>().value!.id;

    if (message.data.isAlohaData) {
      _currentWatchers.join((
        user: message.data.toAlohaData().user,
        isNew: isOther,
      ));
    } else if (message.data.isHereIsData && isOther) {
      _currentWatchers.join((
        user: message.data.toHereIsData().user,
        isNew: false,
      ));
    } else if (message.data.isByeData && isOther) {
      _currentWatchers.leave(message.sender);
    }
  }

  void _answerAloha() {
    final message = _lastMessage.value;
    if (message == null) return;

    final read = context.read;
    if (message.data.isAlohaData &&
        message.sender.id != read<ChatUser>().value!.id) {
      read<ActionsLeaf>().invoke(SendMessageIntent(HereIsMessageData(
        user: read<ChatUser>().value!,
        isTalking: read<VoiceCallStatus>().value == VoiceCallStatusType.talking,
      ).toMessageData()));
    }
  }

  void _sendAloha() {
    if (_currentChannel.value != null) {
      final read = context.read;
      read<ActionsLeaf>().invoke(SendMessageIntent(AlohaMessageData(
        user: read<ChatUser>().value!,
      ).toMessageData()));
    }
  }
}
