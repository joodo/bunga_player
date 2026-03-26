import 'package:flutter/widgets.dart';
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

extension ChatActionsExtension on Widget {
  Widget chatActions() =>
      Actions(actions: {SendMessageIntent: SendMessageAction()}, child: this);
}
