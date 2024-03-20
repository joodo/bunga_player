import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/clients/chat.dart';
import 'package:bunga_player/services/player.dart';
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

final videoPlayingProvider = MultiProvider(
  providers: [
    ChangeNotifierProxyProvider<CurrentChannelFiles, ChannelSubtitles>(
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
