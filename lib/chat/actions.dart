import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/chat/client/client.tencent.dart';
import 'package:bunga_player/play_sync/models.dart';
import 'package:bunga_player/play_sync/providers.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/providers.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'client/client.dart';
import 'models/channel_data.dart';
import 'models/message_data.dart';
import 'models/message.dart';
import 'models/user.dart';
import 'providers.dart';

class UpdateChannelDataIntent extends Intent {
  final ChannelData channelData;
  const UpdateChannelDataIntent(this.channelData);
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

class SendMessageIntent extends Intent {
  final Map<String, dynamic> data;

  const SendMessageIntent(this.data);
}

class SendMessageAction extends ContextAction<SendMessageIntent> {
  final ChatClient client;

  SendMessageAction({required this.client});

  @override
  Future<Message> invoke(
    SendMessageIntent intent, [
    BuildContext? context,
  ]) {
    return client!.sendMessage(intent.data);
  }
}

class RefreshWatchersIntent extends Intent {
  const RefreshWatchersIntent();
}

class ChatActions extends SingleChildStatefulWidget {
  const ChatActions({super.key, super.child});
  @override
  State<ChatActions> createState() => _ChannelActionsState();
}

class _ChannelActionsState extends SingleChildState<ChatActions> {
  final _messageStreamController = StreamController<Message>.broadcast();

  late final _lastMessage = context.read<ChatChannelLastMessage>();

  @override
  void initState() {
    /*
    _currentWatchers.addJoinListener(_notifyUserJoin);
    _currentWatchers.addLeaveListener(_notifyUserLeave);
    _currentChannel.addListener(_sendAloha);
    _lastMessage.addListener(_updateWatchers);
    _lastMessage.addListener(_answerAloha);
*/
    getIt<ExitCallbacks>().add(() async {
      return context.read<ActionsLeaf>().maybeInvoke(
            const LeaveChannelIntent(),
          ) as Future?;
    });

    super.initState();
  }

  @override
  void dispose() {
    _messageStreamController.close();

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Consumer<BungaClientInfo?>(
      builder: (context, clientInfo, child) {
        return FutureBuilder(
          future: clientInfo == null
              ? Future.value(null)
              : TencentClient.create(
                  clientInfo: clientInfo,
                  messageStreamController: _messageStreamController,
                ),
          builder: (context, snapshot) {
            return child!.actions(
                actions: snapshot.hasData
                    ? {
                        SendMessageIntent:
                            SendMessageAction(client: snapshot.data!),
                      }
                    : {});
          },
        );
      },
      child: MultiProvider(
        providers: [
          Provider.value(value: _messageStreamController.stream),
        ],
        child: child,
      ),
    );
  }
}
