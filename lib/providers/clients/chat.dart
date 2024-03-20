import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/providers/chat.dart';

class OwnUser extends User {
  final Future<void> Function() logout;

  OwnUser({
    required super.id,
    required super.name,
    required this.logout,
  });
}

class Channel {
  final String id;

  final ({
    Stream<ChannelData> data,
    Stream<User> joiner,
    Stream<User> leaver,
    Stream<Message> message,
    Stream<ChannelFile> file,
  }) streams;

  final Future<void> Function(ChannelData data) updateData;
  final Future<Message> Function(String text, {String? quoteId}) sendMessage;
  final Stream<UploadProgress> Function(
    String filePath, {
    String? title,
    String? description,
  }) uploadFile;
  final Future<void> Function() leave;

  Channel({
    required this.id,
    required this.streams,
    required this.updateData,
    required this.sendMessage,
    required this.uploadFile,
    required this.leave,
  });
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

abstract class ChatClient {
  Future<OwnUser> login(String id, String token, String? name);
  Future<void> logout();

  Future<List<({String id, ChannelData data})>> queryOnlineChannels();
  Future<Channel> joinChannel(ChannelJoinPayload payload);
}
