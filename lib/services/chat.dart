import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';

typedef JoinChannelPayload = (
  String id,
  Iterable<User> watchers,
  Stream<ChannelData> channelDataStream,
  Stream<User> joinerStream,
  Stream<User> leaverStream,
  Stream<Message> messageStream,
);

abstract class ChatService {
  String get appKey;

  Future<void> login(String id, String token, String? name);
  Future<void> logout();
  Future<User> renameUser(User user, String newName);

  Future<List<(String id, ChannelData data)>> queryOnlineChannels();
  Future<JoinChannelPayload> createOrJoinChannelByData(ChannelData data);
  Future<JoinChannelPayload> joinChannelById(String id);
  Future<void> leaveChannel();

  Future<void> updateChannelData(ChannelData data);
  Future<Message> sendMessage(String text, String? quoteId);
}
