import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class Danmaku {
  final User sender;
  final String text;

  Danmaku({required this.sender, required this.text});
}

class LastDanmakuNotifier extends ValueNotifier<Danmaku?> {
  LastDanmakuNotifier() : super(null);
}

final danmakuProvider = MultiProvider(
  providers: [
    ChangeNotifierProxyProvider<ChatChannelLastMessage, LastDanmakuNotifier>(
      create: (context) => LastDanmakuNotifier(),
      update: (context, channelMessageNotifer, previous) {
        const prefix = 'danmaku ';

        final message = channelMessageNotifer.value;
        if (message == null) {
          previous!.value = null;
        } else if (message.text.startsWith(prefix)) {
          previous!.value = Danmaku(
            sender: message.sender,
            text: message.text.substring(prefix.length),
          );
        }

        return previous!;
      },
    ),
  ],
);
