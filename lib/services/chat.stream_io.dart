import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart'
    as stream;

typedef AgoraChannelDataPayload = (
  String channelId,
  int userId,
  String token,
);

class StreamIO implements ChatService {
  StreamIO(this.appKey)
      : _client = stream.StreamChatClient(
          appKey,
          logLevel: stream.Level.WARNING,
        );
  final stream.StreamChatClient _client;

  @override
  final String appKey;

  // User
  static User userFromStreamUser(stream.User streamUser) =>
      User(id: streamUser.id, name: streamUser.name);

  @override
  Future<void> login(String id, String token, String? name) async {
    await _client.connectUser(
      stream.User(
        id: id,
        name: name,
      ),
      token,
    );
  }

  @override
  Future<void> logout() => _client.disconnectUser();

  @override
  Future<User> renameUser(User user, String newName) async {
    if (user.name == newName) return user;

    await _client.updateUser(stream.User(id: user.id, name: newName));
    return User(id: user.id, name: newName);
  }

  // Channel
  stream.Channel? _currentChannel;

  @override
  Future<JoinChannelPayload> createOrJoinChannelByData(ChannelData data) async {
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
    _currentChannel = channel;

    return _getReturnByStreamChannel(channel);
  }

  @override
  Future<JoinChannelPayload> joinChannelById(String id) async {
    final channel = _client.channel(
      'livestream',
      id: id,
    );
    await channel.watch();
    _currentChannel = channel;

    return await _getReturnByStreamChannel(channel);
  }

  Future<JoinChannelPayload> _getReturnByStreamChannel(
      stream.Channel channel) async {
    // Watchers won't auto fetch
    final state = await channel.query(
      watch: true,
      // watchers won't query if no pagination
      watchersPagination: const stream.PaginationParams(limit: 1000),
    );

    final watchers = await _updateUsers(state.watchers!);

    return (
      channel.cid!,
      watchers.map(userFromStreamUser),
      channel.extraDataStream
          .map<ChannelData>((data) => ChannelData.fromJson(data)),
      channel.on('user.watching.start').asyncMap<User>(_getUpdatedEventUser),
      channel.on('user.watching.stop').asyncMap<User>(_getUpdatedEventUser),
      channel.on('message.new').map<Message>(
            (event) => Message(
              id: event.message!.id,
              text: event.message!.text!,
              sender: userFromStreamUser(event.message!.user!),
              quoteId: event.message!.quotedMessageId,
            ),
          ),
    );
  }

  Future<User> _getUpdatedEventUser(stream.Event event) async {
    final streamUser = event.user!;
    // User name won't update if he renamed recently
    final updateUser = (await _updateUsers([streamUser])).first;
    return User(
      id: updateUser.id,
      name: updateUser.name,
    );
  }

  @override
  Future<List<(String id, ChannelData data)>> queryOnlineChannels() async {
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
        .map(
            (channel) => (channel.id!, ChannelData.fromJson(channel.extraData)))
        .toList();
  }

  Future<List<stream.User>> _updateUsers(Iterable<stream.User> users) async {
    final response = await _client.queryUsers(
        filter: stream.Filter.in_(
      'id',
      users.map((user) => user.id).toList(),
    ));
    return response.users;
  }

  @override
  Future<void> leaveChannel() async {
    assert(_currentChannel != null);
    await _currentChannel!.stopWatching();
    _currentChannel = null;
  }

  @override
  Future<Message> sendMessage(String text, String? quoteId) async {
    var message = stream.Message(text: text, quotedMessageId: quoteId);

    assert(_currentChannel != null);
    // Message id was generated when message was created, so no need to await
    _currentChannel!.sendMessage(
      message,
      skipPush: true,
    );

    return Message(
      id: message.id,
      text: text,
      sender: userFromStreamUser(_client.state.currentUser!),
      quoteId: quoteId,
    );
  }

  @override
  Future<void> updateChannelData(ChannelData data) async {
    assert(_currentChannel != null);
    await _currentChannel!.updatePartial(set: data.toJson());
  }

  Future<AgoraChannelDataPayload> getAgoraChannelData() async {
    assert(_currentChannel?.id != null);

    final callResponse = await _client.createCall(
      callId: _currentChannel!.id!,
      callType: 'audio',
      channelType: 'livestream',
      channelId: _currentChannel!.id!,
    );
    final call = callResponse.call!;

    final tokenResponse = await _client.getCallToken(call.id);

    return (
      call.agora!.channel,
      tokenResponse.agoraUid!,
      tokenResponse.token!,
    );
  }
}
