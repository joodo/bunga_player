import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/track.dart';
import 'package:bunga_player/play/models/video_entries/video_entry.dart';
import 'package:bunga_player/play/providers.dart';

// Subtitle
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

// Channel join payload
sealed class ChannelJoinPayload {}

class ChannelJoinByIdPayload extends ChannelJoinPayload {
  final String id;
  ChannelJoinByIdPayload(this.id);
}

class ChannelJoinByEntryPayload extends ChannelJoinPayload {
  final VideoEntry videoEntry;
  ChannelJoinByEntryPayload(this.videoEntry);
}

// Message data
class PlayStatusMessageData {
  final PlayStatusType status;
  final Duration position;
  final String? answerId;

  PlayStatusMessageData({
    required this.status,
    required this.position,
    required this.answerId,
  });

  MessageData toMessageData() => {
        'type': 'playStatus',
        'status': status.name,
        'position': position.inMilliseconds,
        'answerId': answerId,
      };
}

class WhereAskingMessageData {
  MessageData toMessageData() => {'type': 'where'};
}

extension PlayStatusExtension on MessageData {
  bool get isPlayStatus => this['type'] == 'playStatus';
  PlayStatusMessageData toPlayStatus() => isPlayStatus
      ? PlayStatusMessageData(
          status: PlayStatusType.values.byName(this['status']),
          position: Duration(milliseconds: this['position']),
          answerId: this['answerId'],
        )
      : throw const FormatException();

  bool get isWhereAsking => this['type'] == 'where';
}
