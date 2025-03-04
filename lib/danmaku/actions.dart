import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/danmaku/models.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class SendDanmakuIntent extends Intent {
  final String text;

  const SendDanmakuIntent(this.text);
}

class SendDanmakuAction extends ContextAction<SendDanmakuIntent> {
  @override
  Future<void> invoke(SendDanmakuIntent intent, [BuildContext? context]) {
    throw UnimplementedError();
    /*
    return Actions.invoke(
      context!,
      SendMessageIntent(DanmakuMessageData(text: intent.text).toMessageData()),
    ) as Future<void>;
    */
  }
}

class DanmakuActions extends SingleChildStatelessWidget {
  const DanmakuActions({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      actions: <Type, Action<Intent>>{
        SendDanmakuIntent: SendDanmakuAction(),
      },
      child: child!,
    );
  }
}
