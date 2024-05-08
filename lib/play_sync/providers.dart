import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/chat/client/client.dart';
import 'package:bunga_player/player/providers.dart';
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
  providers: [
    ChangeNotifierProxyProvider<ChatChannelFiles, ChannelSubtitles>(
      create: (context) => ChannelSubtitles(),
      update: (context, channelFiles, previous) {
        const prefix = 'subtitle ';
        final subFiles = channelFiles.value.where((channelFile) =>
            channelFile.description?.startsWith(prefix) ?? false);

        final m = <String, ChannelFile>{};
        for (final file in subFiles) {
          m[file.uploader.id] = file;
        }

        previous!.value = m.map(
          (userId, channelFile) => MapEntry<String, ChannelSubtitle>(
            userId,
            previous.value[userId]?.id == channelFile.id
                ? previous.value[userId]!
                : ChannelSubtitle(
                    id: channelFile.id,
                    sharer: channelFile.uploader,
                    title: channelFile.description!.substring(prefix.length),
                    url: channelFile.url,
                  ),
          ),
        );
        return previous;
      },
      lazy: false,
    ),
  ],
);
