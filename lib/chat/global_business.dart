import 'dart:async';

import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/chat/client/client.bunga.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'client/client.dart';
import 'models/message_data.dart';
import 'models/message.dart';

class SendMessageIntent extends Intent {
  final MessageData data;

  const SendMessageIntent(this.data);
}

class SendMessageAction extends ContextAction<SendMessageIntent> {
  SendMessageAction();

  @override
  Future<Message?> invoke(SendMessageIntent intent, [BuildContext? context]) {
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

  @override
  void dispose() {
    _messageStreamController.close();

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);

    final actions = Actions(
      actions: {SendMessageIntent: SendMessageAction()},
      child: child!,
    );

    final selector = Selector<ChatClient?, Stream<Message>?>(
      selector: (context, client) => client?.messageStream,
      builder: (context, stream, child) {
        // bind stream
        stream?.listen(_messageStreamController.add);

        // send aloha request
        final job =
            Actions.invoke(context, AlohaIntent()) as Future<AlohaResponse?>;
        job.then((data) {
          if (data == null) return;

          // mock projection message
          _messageStreamController.add(
            Message(
              data: StartProjectionMessageData(
                videoRecord: data.videoRecord,
              ).toJson(),
              sender: data.user,
            ),
          );
        });

        return child!;
      },
      child: actions,
    );

    return MultiProvider(
      providers: [
        Provider.value(value: _messageStreamController.stream),
        ProxyProvider<BungaServerInfo?, Future<ChatClient?>>(
          update: (context, serverInfo, previous) {
            previous?.then((client) => client?.dispose());

            if (serverInfo == null) return Future.value(null);

            return BungaChatClient.create(serverInfo: serverInfo);
          },
        ),
        ProxyFutureProvider<BungaServerInfo?, ChatClient?>(
          create: (info) => info != null
              ? BungaChatClient.create(serverInfo: info)
              : Future.value(null),
          dispose: (client) => client?.dispose(),
        ),
      ],
      child: selector,
    );
  }
}
