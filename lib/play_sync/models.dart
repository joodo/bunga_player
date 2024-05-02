import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/player/models/video_entries/video_entry.dart';
import 'package:bunga_player/player/service/service.dart';

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

sealed class ChannelJoinPayload {}

class ChannelJoinByIdPayload extends ChannelJoinPayload {
  final String id;
  ChannelJoinByIdPayload(this.id);
}

class ChannelJoinByEntryPayload extends ChannelJoinPayload {
  final VideoEntry videoEntry;
  ChannelJoinByEntryPayload(this.videoEntry);
}
