import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';

class ChannelStreams {
  final Stream<ChannelData> channelData;
  final Stream<User> joiner;
  final Stream<User> leaver;
  final Stream<Message> message;
  final Stream<ChannelFile> file;

  ChannelStreams({
    required this.channelData,
    required this.joiner,
    required this.leaver,
    required this.message,
    required this.file,
  });
}

class JoinChannelResponse {
  final String id;
  final ChannelStreams streams;

  JoinChannelResponse({required this.id, required this.streams});
}

class ChannelFile {
  final String id;
  final String title;
  final User uploader;
  final String url;
  final String? description;

  ChannelFile({
    required this.id,
    required this.title,
    required this.uploader,
    required this.url,
    this.description,
  });

  @override
  String toString() {
    return '$title ($description) by $uploader';
  }
}

class UploadProgress {
  final int current;
  final int total;

  UploadProgress(this.current, this.total);
}

abstract class ChatService {
  Future<void> login(String id, String token, String? name);
  Future<void> logout();

  Future<List<(String id, ChannelData data)>> queryOnlineChannels();
  Future<JoinChannelResponse> createOrJoinChannelByData(ChannelData data);
  Future<JoinChannelResponse> joinChannelById(String id);
  Future<void> leaveChannel();

  Future<void> updateChannelData(ChannelData data);
  Future<Message> sendMessage(String text, {String? quoteId});
  Stream<UploadProgress> uploadFile(
    String filePath, {
    String? title,
    String? description,
  });
}
