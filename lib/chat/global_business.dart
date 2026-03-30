import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '/bunga_server/models/channel_tokens.dart';
import '/utils/utils.dart';

import 'client/client.bunga.dart';
import 'client/client.dart';
import 'models/models.dart';

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
        Future.delayed(2.seconds, () {
          final data = WhatsOnMessageData();
          client.sendMessage(data.toJson());
        });
      }
    });

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
      child: listener,
    );
  }
}
