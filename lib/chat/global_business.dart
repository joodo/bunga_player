import 'dart:async';

import 'package:bunga_player/bunga_server/models/channel_tokens.dart';
import 'package:bunga_player/chat/client/client.bunga.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/extensions/listen_provider.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'client/client.dart';
import 'models/models.dart';

class SendMessageIntent extends Intent {
  final MessageData data;

  const SendMessageIntent(this.data);
}

extension SendMessage on BuildContext {
  Future<JsonMessage?> sendMessage(MessageData data) =>
      Actions.invoke(this, SendMessageIntent(data)) as Future<JsonMessage?>;
}

class SendMessageAction extends ContextAction<SendMessageIntent> {
  SendMessageAction();

  @override
  Future<JsonMessage?> invoke(
    SendMessageIntent intent, [
    BuildContext? context,
  ]) {
    final client = context!.read<ChatClient>();
    return client.sendMessage(intent.data.toJson());
  }

  @override
  bool isEnabled(SendMessageIntent intent, [BuildContext? context]) {
    return context?.read<ChatClient?>() != null;
  }
}

class ChatGlobalBusiness extends SingleChildStatefulWidget {
  const ChatGlobalBusiness({super.key, super.child});
  @override
  State<ChatGlobalBusiness> createState() => _ChannelActionsState();
}

class _ChannelActionsState extends SingleChildState<ChatGlobalBusiness> {
  final _messageStreamController = StreamController<Message>.broadcast();
  StreamSubscription? _clientSubscription;

  @override
  void dispose() {
    _messageStreamController.close();
    _clientSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);

    final listener = child!.listenProvider<ChatClient?>((context, client) {
      _clientSubscription?.cancel();

      if (client != null) {
        // bind stream
        _clientSubscription = client.messageStream.listen(
          (message) => _messageStreamController.add(Message.fromJson(message)),
        );

        // Wait in case the playback service has not finished initializing after automatically entering the channel
        Future.delayed(const Duration(seconds: 2), () {
          final data = WhatsOnMessageData();
          client.sendMessage(data.toJson());
        });
      }
    });

    final actions = Actions(
      actions: {SendMessageIntent: SendMessageAction()},
      child: listener,
    );

    return MultiProvider(
      providers: [
        Provider.value(value: _messageStreamController.stream),
        ProxyFutureProvider<ChannelTokens?, ChatClient?>(
          create: (info) => info != null
              ? BungaChatClient.create(serverInfo: info)
              : Future.value(null),
          dispose: (client) => client?.dispose(),
        ),
      ],
      child: actions,
    );
  }
}
