import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

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

class DanmakuActions extends SingleChildStatelessWidget {
  const DanmakuActions({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'Danmaku'),
      actions: <Type, Action<Intent>>{
        SendDanmakuIntent: SendDanmakuAction(),
      },
      child: child!,
    );
  }
}
