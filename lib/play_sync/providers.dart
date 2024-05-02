import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/chat/client/client.dart';
import 'package:bunga_player/player/service/service.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class ChannelSubtitle {
  final String id;
  final String title;
  final User sharer;
  final String url;

  SubtitleTrack? _track;
  SubtitleTrack? get track => _track;
  set track(SubtitleTrack? value) {
    if (_track == null) {
      _track = value;
    } else {
      throw Exception('Variable already initiated');
    }
  }

  ChannelSubtitle({
    required this.id,
    required this.title,
    required this.sharer,
    required this.url,
  });
}

class ChannelSubtitles extends ValueNotifier<Map<String, ChannelSubtitle>> {
  ChannelSubtitles() : super({});
}

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
    ),
  ],
);
