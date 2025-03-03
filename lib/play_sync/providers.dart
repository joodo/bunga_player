import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/chat/client/client.dart';
import 'package:bunga_player/play/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'models.dart';

extension IsVideoSameWithChannel on BuildContext {
  bool get isVideoSameWithChannel =>
      read<ChatChannelData>().value?.videoHash ==
      read<PlayVideoEntry>().value?.hash;
}

class ChannelSubtitles extends ValueNotifier<Map<String, ChannelSubtitle>> {
  ChannelSubtitles() : super({});
}

class ChatChannelJoinPayload extends ValueNotifier<ChannelJoinPayload?> {
  ChatChannelJoinPayload() : super(null);
}

final channelJoiningProvider = MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (context) => ChatChannelJoinPayload(),
      lazy: false,
    ),
  ],
);

final playSyncProvider = MultiProvider(
  providers: [],
);
