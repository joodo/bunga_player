import 'dart:async';

import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/chat/client/client.tencent.dart';
import 'package:bunga_player/play_sync/models.dart';
import 'package:bunga_player/play_sync/providers.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'models/channel_data.dart';
import 'models/message_data.dart';
import 'models/message.dart';

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

class SendMessageIntent extends Intent {
  final MessageData data;

  const SendMessageIntent(this.data);
}

class SendMessageAction extends ContextAction<SendMessageIntent> {
  SendMessageAction();

  @override
  Future<Message> invoke(
    SendMessageIntent intent, [
    BuildContext? context,
  ]) {
    final client = context!.read<TencentClient>();
    return client.sendMessage(intent.data.toJson());
  }

  @override
  bool isEnabled(SendMessageIntent intent, [BuildContext? context]) {
    return context?.read<TencentClient?>() != null;
  }
}

class ChatActions extends SingleChildStatefulWidget {
  const ChatActions({super.key, super.child});
  @override
  State<ChatActions> createState() => _ChannelActionsState();
}

class _ChannelActionsState extends SingleChildState<ChatActions> {
  final _messageStreamController = StreamController<Message>.broadcast();

  @override
  void dispose() {
    _messageStreamController.close();

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        Provider.value(value: _messageStreamController.stream),
        ProxyFutureProvider<TencentClient?, BungaClientInfo?>(
          proxy: (clientInfo) => clientInfo == null
              ? null
              : TencentClient.create(
                  clientInfo: clientInfo,
                  messageStreamController: _messageStreamController,
                ),
          initialData: null,
        ),
      ],
      child: child!.actions(actions: {
        SendMessageIntent: SendMessageAction(),
      }),
    );
  }
}
