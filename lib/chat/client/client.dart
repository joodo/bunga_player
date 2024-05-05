import 'dart:convert';

import 'package:bunga_player/utils/models/network_progress.dart';

import '../models/channel_data.dart';
import '../models/message.dart';
import '../models/user.dart';

class OwnUser extends User {
  final Future<void> Function() logout;

  OwnUser({
    required super.id,
    required super.name,
    required this.logout,
    super.colorHue,
  });
}

class RawMessage {
  final String id;
  final String text;
  final User sender;

  RawMessage({
    required this.id,
    required this.text,
    required this.sender,
  });

  Message toMessage() => Message(
        id: id,
        data: jsonDecode(text) as MessageData,
        sender: sender,
      );
}

typedef JoinEvent = ({
  User user,
  bool isNew,
});

class Channel {
  final String id;

  final ({
    Stream<ChannelData> data,
    Stream<RawMessage> message,
    Stream<ChannelFile> file,
  }) streams;

  final Future<void> Function(ChannelData data) updateData;
  final Future<RawMessage> Function(String text) sendMessage;
  final Stream<RequestProgress> Function(
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

abstract class ChatClient {
  Future<OwnUser> login(String id, String token, String? name, {int? colorHue});
  Future<List<({String id, ChannelData data})>> queryOnlineChannels();
  Future<Channel> joinChannelById(String id);
  Future<Channel> joinChannelByData(ChannelData data);
}
