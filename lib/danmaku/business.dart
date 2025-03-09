import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

// Data types

class RecentPopmojisNotifier extends ValueNotifier<List<String>> {
  RecentPopmojisNotifier()
      : super(["🎆", "😆", "😭", "😍", "🤤", "🫣", "🤮", "🤡", "🔥"]) {
    bindPreference<List<String>>(
      preferences: getIt<Preferences>(),
      key: 'recent_popmojis',
      load: (pref) => value,
      update: (value) => value,
    );
  }
}

// Actions

@immutable
class SendPopmojiIntent extends Intent {
  final String code;
  const SendPopmojiIntent(this.code);
}

class SendPopmojiAction extends ContextAction<SendPopmojiIntent> {
  @override
  void invoke(SendPopmojiIntent intent, [BuildContext? context]) {
    final messageData = PopmojiMessageData(
      code: intent.code,
      sender: User.fromContext(context!),
    );
    Actions.invoke(context, SendMessageIntent(messageData));
  }
}

@immutable
class SendDanmakuIntent extends Intent {
  final String message;
  const SendDanmakuIntent(this.message);
}

class SendDanmakuAction extends ContextAction<SendDanmakuIntent> {
  @override
  void invoke(SendDanmakuIntent intent, [BuildContext? context]) {
    final messageData = DanmakuMessageData(
      message: intent.message,
      sender: User.fromContext(context!),
    );
    Actions.invoke(context, SendMessageIntent(messageData));
  }
}

// Wrapper

class DanmakuBusiness extends SingleChildStatefulWidget {
  const DanmakuBusiness({super.key, super.child});

  @override
  State<DanmakuBusiness> createState() => _DanmakuBusinessState();
}

class _DanmakuBusinessState extends SingleChildState<DanmakuBusiness> {
  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecentPopmojisNotifier()),
      ],
      child: child!.actions(actions: {
        SendPopmojiIntent: SendPopmojiAction(),
        SendDanmakuIntent: SendDanmakuAction(),
      }),
    );
  }
}

extension WrapDanmakuBusiness on Widget {
  Widget danmakuBusiness() => DanmakuBusiness(child: this);
}
