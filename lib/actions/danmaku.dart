import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/screens/wrappers/shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SendDanmakuIntent extends Intent {
  final String text;

  const SendDanmakuIntent(this.text);
}

class SendDanmakuAction extends ContextAction<SendDanmakuIntent> {
  @override
  Future<void> invoke(SendDanmakuIntent intent, [BuildContext? context]) {
    return Actions.invoke(
      context!,
      SendMessageIntent('danmaku ${intent.text}'),
    ) as Future<void>;
  }
}

class DanmakuActions extends StatefulWidget {
  final Widget child;
  const DanmakuActions({super.key, required this.child});

  @override
  State<DanmakuActions> createState() => _DanmakuActionsState();
}

class _DanmakuActionsState extends State<DanmakuActions> {
  @override
  void initState() {
    context.read<CurrentChannelMessage>().addListener(_dealChannelMessage);
    super.initState();
  }

  @override
  void dispose() {
    context.read<CurrentChannelMessage>().removeListener(_dealChannelMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'Danmaku'),
      actions: <Type, Action<Intent>>{
        SendDanmakuIntent: SendDanmakuAction(),
      },
      child: widget.child,
    );
  }

  void _dealChannelMessage() {
    final read = Intentor.context.read;

    final message = read<CurrentChannelMessage>().value!;

    const prefix = 'danmaku ';
    if (message.text.startsWith(prefix)) {
      read<LastDanmaku>().value = Danmaku(
        sender: message.sender,
        text: message.text.substring(prefix.length),
      );
    }
  }
}
