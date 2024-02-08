import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

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
      : _client = StreamChatClient(
          appKey,
          logLevel: Level.WARNING,
        );
  final StreamChatClient _client;
  final String appKey;

  // User
  Future<void> login(String id, String token, String? name) async {
    await _client.connectUser(
      User(
        id: id,
        name: name,
      ),
      token,
    );
  }

  Future<void> logout() => _client.disconnectUser();

  User? get currentUser => _client.state.currentUser;

  Future<void> updateUserInfo(CurrentUser user) async {
    await _client.updateUser(User(
      id: user.id,
      name: user.name,
    ));
  }

  // Channel
  Future<Channel> createOrJoinChannelByData(ChannelData data) async {
    Channel channel;

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

  Future<Channel> joinChannelById(String id) async {
    final channel = _client.channel(
      'livestream',
      id: id,
    );
    await channel.watch();
    return channel;
  }

  Future<List<(String id, ChannelData channelData)>>
      queryOnlineChannels() async {
    final filter =
        Filter.equal(ChannelData.videoTypeJsonKey, VideoType.online.name);
    final channels = await _client
        .queryChannels(
          filter: filter,
          channelStateSort: [
            const SortOption('last_message_at', direction: SortOption.DESC)
          ],
          watch: false,
          state: false,
        )
        .last;
    return channels
        .map((channel) => (
              channel.id!,
              ChannelData.fromJson(channel.extraData),
            ))
        .toList();
  }

  Future<List<User>> updateUsers(List<User> users) async {
    final response = await _client.queryUsers(
        filter: Filter.in_(
      'id',
      users.map((user) => user.id).toList(),
    ));
    return response.users;
  }

  Future leaveChannel(Channel channel) async {
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
