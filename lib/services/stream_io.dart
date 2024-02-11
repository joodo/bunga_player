import 'package:bunga_player/models/chat/channel.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart'
    as stream;

class VoiceCallChannelData {
  VoiceCallChannelData({
    required this.id,
    required this.uid,
    required this.token,
  });
  final String id, token;
  final int uid;

  @override
  String toString() => 'cid: $id\nuid: $uid\ntoken: $token';
}

class StreamIO {
  StreamIO(this.appKey)
      : _client = stream.StreamChatClient(
          appKey,
          logLevel: stream.Level.WARNING,
        );
  final stream.StreamChatClient _client;
  final String appKey;

  // User
  static User userFromStreamUser(stream.User streamUser) =>
      User(id: streamUser.id, name: streamUser.name);

  Future<void> login(String id, String token, String? name) async {
    await _client.connectUser(
      stream.User(
        id: id,
        name: name,
      ),
      token,
    );
  }

  Future<void> logout() => _client.disconnectUser();

  Future<User> renameUser(User user, String newName) async {
    if (user.name == newName) return user;

    await _client.updateUser(stream.User(id: user.id, name: newName));
    return User(id: user.id, name: newName);
  }

  // Channel
  Future<stream.Channel> createOrJoinChannelByData(ChannelData data) async {
    stream.Channel channel;

    for (int suffix = 0; true; suffix++) {
      // Unique id
      final id = suffix == 0 ? data.videoHash : '${data.videoHash}-$suffix';
      channel = _client.channel(
        'livestream',
        id: id,
        extraData: data.toJson(),
      );

      final state = await channel.query();
      if (state.channel?.extraData['hash'] == data.videoHash) break;

      logger.i(
          'Channel id $id was changed hash to ${state.channel?.extraData['hash']}, try next one.');
    }

    await channel.watch();
    return channel;
  }

  Future<stream.Channel> joinChannelById(String id) async {
    final channel = _client.channel(
      'livestream',
      id: id,
    );
    await channel.watch();
    return channel;
  }

  Future<List<Channel>> queryOnlineChannels() async {
    final filter = stream.Filter.equal(
        ChannelData.videoTypeJsonKey, VideoType.online.name);
    final channels = await _client
        .queryChannels(
          filter: filter,
          channelStateSort: [
            const stream.SortOption('last_message_at',
                direction: stream.SortOption.DESC)
          ],
          watch: false,
          state: false,
        )
        .last;
    return channels
        .map((channel) => Channel(
              id: channel.id!,
              createdAt: channel.createdAt!,
              updatedAt: channel.updatedAt!,
              creator: userFromStreamUser(channel.createdBy!),
              data: ChannelData.fromJson(channel.extraData),
            ))
        .toList();
  }

  Future<List<stream.User>> updateUsers(List<stream.User> users) async {
    final response = await _client.queryUsers(
        filter: stream.Filter.in_(
      'id',
      users.map((user) => user.id).toList(),
    ));
    return response.users;
  }

  Future leaveChannel(stream.Channel channel) async {
    return await channel.stopWatching();
  }

  Future<VoiceCallChannelData> createVoiceCall(String channelId) async {
    final callResponse = await _client.createCall(
      callId: channelId,
      callType: 'audio',
      channelType: 'livestream',
      channelId: channelId,
    );
    final call = callResponse.call!;

    final tokenResponse = await _client.getCallToken(call.id);

    return VoiceCallChannelData(
      id: call.agora!.channel,
      uid: tokenResponse.agoraUid!,
      token: tokenResponse.token!,
    );
  }
}
