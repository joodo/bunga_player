import 'dart:async';
import 'dart:io';

import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart'
    as stream;
import 'package:path/path.dart' as path;

typedef AgoraChannelDataPayload = (
  String channelId,
  int userId,
  String token,
);

class StreamIO implements ChatService {
  StreamIO(String appKey)
      : _client = stream.StreamChatClient(
          appKey,
          logLevel: stream.Level.WARNING,
        );
  final stream.StreamChatClient _client;

  // User
  static User _userFromStreamUser(stream.User streamUser) =>
      User(id: streamUser.id, name: streamUser.name);

  @override
  Future<void> login(String id, String token, String? name) async {
    if (_client.state.currentUser != null) await _client.disconnectUser();
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

  // Channel
  stream.Channel? _currentChannel;

  @override
  Future<JoinChannelResponse> createOrJoinChannelByData(
      ChannelData data) async {
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

    return _getResponseByStreamChannel(channel);
  }

  @override
  Future<JoinChannelResponse> joinChannelById(String id) async {
    final channel = _client.channel(
      'livestream',
      id: id,
    );
    await channel.watch();
    _currentChannel = channel;

    return _getResponseByStreamChannel(channel);
  }

  ChannelFile _fileFromStreamMessage(stream.Message message) {
    assert(message.text!.startsWith('file '));
    assert(message.attachments.isNotEmpty);
    return ChannelFile(
      id: message.id,
      title: message.attachments[0].title!,
      uploader: _userFromStreamUser(message.user!),
      url: message.attachments[0].assetUrl!,
      description: message.text!.substring(5),
    );
  }

  JoinChannelResponse _getResponseByStreamChannel(stream.Channel channel) {
    final joinerStreamController = StreamController<User>.broadcast();
    final fileStreamController = StreamController<ChannelFile>.broadcast();

    // Watchers won't auto fetch
    channel
        .query(
      watch: true,
      // watchers won't query if no pagination
      watchersPagination: const stream.PaginationParams(limit: 1000),
    )
        .then(
      (state) {
        // watchers
        _updateUsers(state.watchers!).then(
          (watchers) {
            // push users that already watched
            for (final user in watchers) {
              joinerStreamController.add(_userFromStreamUser(user));
            }
            // then follow stream
            joinerStreamController.addStream(
              channel
                  .on('user.watching.start')
                  .asyncMap<User>(_getUpdatedEventUser),
            );
          },
        );

        // files
        final pinnedMessages = state.pinnedMessages
          ?..sort(
            (a, b) => a.pinnedAt!.compareTo(b.pinnedAt!),
          );
        // already uploaded
        for (final message in pinnedMessages ?? []) {
          fileStreamController.add(_fileFromStreamMessage(message));
        }
        // then follow stream
        fileStreamController.addStream(
          channel
              .on('message.new')
              .where(
                  (event) => event.message?.text?.startsWith('file ') ?? false)
              .map<ChannelFile>(
                  (event) => _fileFromStreamMessage(event.message!)),
        );
      },
    );

    return JoinChannelResponse(
      id: channel.cid!,
      streams: ChannelStreams(
        channelData: channel.extraDataStream
            .map<ChannelData>((data) => ChannelData.fromJson(data))
            .distinct(),
        joiner: joinerStreamController.stream.distinct(),
        leaver: channel
            .on('user.watching.stop')
            .asyncMap<User>(_getUpdatedEventUser)
            .distinct(),
        message: channel.on('message.new').map<Message>(
              (event) => Message(
                id: event.message!.id,
                text: event.message!.text!,
                sender: _userFromStreamUser(event.message!.user!),
                quoteId: event.message!.quotedMessageId,
              ),
            ),
        file: fileStreamController.stream,
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
  Future<Message> sendMessage(String text, {String? quoteId}) async {
    final message = stream.Message(text: text, quotedMessageId: quoteId);

    assert(_currentChannel != null);
    // Message id was generated when message was created, so no need to await
    _currentChannel!.sendMessage(
      message,
      skipPush: true,
    );

    return Message(
      id: message.id,
      text: text,
      sender: _userFromStreamUser(_client.state.currentUser!),
      quoteId: quoteId,
    );
  }

  @override
  Stream<UploadProgress> uploadFile(
    String filePath, {
    String? title,
    String? description,
  }) {
    assert(_currentChannel != null);

    final progress = StreamController<UploadProgress>();

    File(filePath).length().then((size) {
      final attachmentFile = stream.AttachmentFile(
        size: size,
        path: filePath,
      );
      return _currentChannel!.sendFile(
        attachmentFile,
        onSendProgress: (count, total) {
          progress.add(UploadProgress(count, total));
        },
      );
    }).then((response) {
      final message = stream.Message(
        text: 'file $description',
        pinned: true,
        attachments: [
          stream.Attachment(
            title: title ?? path.basenameWithoutExtension(filePath),
            assetUrl: response.file,
          ),
        ],
      );

      return _currentChannel!.sendMessage(
        message,
        skipPush: true,
      );
    }).then((_) => progress.close());

    return progress.stream;
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
