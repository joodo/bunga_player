import 'dart:async';
import 'dart:io';

import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/models/network_progress.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart'
    as stream;
import 'package:path/path.dart' as path;

import '../models/channel_data.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../providers.dart';
import 'client.dart';

typedef AgoraChannelDataPayload = ({
  String channelId,
  int userId,
  String token,
});

class StreamIOClient implements ChatClient {
  StreamIOClient(String appKey)
      : _client = stream.StreamChatClient(
          appKey,
          logLevel: stream.Level.WARNING,
        );
  final stream.StreamChatClient _client;

  // User
  User _userFromStreamUser(stream.User streamUser) => User(
        id: streamUser.id,
        name: streamUser.name,
        colorHue: streamUser.extraData['color_hue'] as int?,
      );

  @override
  Future<OwnUser> login(
    String id,
    String token,
    String? name, {
    int? colorHue,
  }) async {
    await _logout();
    final streamUser = stream.User(
      id: id,
      name: name,
      extraData: {'color_hue': colorHue},
    );
    await _client.connectUser(
      streamUser,
      token,
    );
    return OwnUser(
      id: id,
      name: name ?? '',
      colorHue: colorHue,
      logout: () async {
        if (id != _client.state.currentUser?.id) return;
        return _logout();
      },
    );
  }

  Future<void> _logout() async {
    if (_client.state.currentUser == null) return;
    return _client.disconnectUser();
  }

  // Channel
  @override
  Future<Channel> joinChannel(ChannelJoinPayload payload) {
    switch (payload) {
      case ChannelJoinByIdPayload():
        return _joinChannelById(payload.id);
      case ChannelJoinByDataPayload():
        return _createOrJoinChannelByData(payload.data);
    }
  }

  Future<Channel> _createOrJoinChannelByData(ChannelData data) async {
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

    return _getResponseByStreamChannel(channel);
  }

  Future<Channel> _joinChannelById(String id) async {
    final channel = _client.channel(
      'livestream',
      id: id,
    );
    await channel.watch();

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

  Channel _getResponseByStreamChannel(stream.Channel channel) {
    final joinerStreamController = StreamController<JoinEvent>.broadcast();
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
        _updateUsers(state.watchers ?? []).then(
          (watchers) {
            // push users that already watched
            for (final user in watchers) {
              joinerStreamController.add((
                user: _userFromStreamUser(user),
                isNew: false,
              ));
            }
            // then follow stream
            joinerStreamController.addStream(
              channel.on('user.watching.start').asyncMap((event) async => (
                    user: await _getUpdatedEventUser(event),
                    isNew: true,
                  )),
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

    return Channel(
      id: channel.id!,
      streams: (
        data: channel.extraDataStream
            .map<ChannelData>((data) => ChannelData.fromJson(data))
            .distinct(),
        joinEvents: joinerStreamController.stream.distinct(),
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
      sendMessage: (text, {quoteId}) => _sendMessage(
        channel,
        text,
        quoteId: quoteId,
      ),
      updateData: (data) => _updateChannelData(channel, data),
      uploadFile: (filePath, {description, title}) => _uploadFile(
        channel,
        filePath,
        description: description,
        title: title,
      ),
      leave: channel.stopWatching,
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
  Future<List<({String id, ChannelData data})>> queryOnlineChannels() async {
    final filter = stream.Filter.equal(
        ChannelData.videoTypeJsonKey, VideoType.online.name);
    final channels = await _client
        .queryChannels(
          filter: filter,
          channelStateSort: [
            const stream.SortOption('created_at',
                direction: stream.SortOption.DESC)
          ],
          watch: false,
          state: false,
        )
        .last;
    return channels
        .map((channel) => (
              id: channel.id!,
              data: ChannelData.fromJson(channel.extraData),
            ))
        .toList();
  }

  Future<List<stream.User>> _updateUsers(Iterable<stream.User> users) async {
    if (users.isEmpty) return [];
    final response = await _client.queryUsers(
        filter: stream.Filter.in_(
      'id',
      users.map((user) => user.id).toList(),
    ));
    return response.users;
  }

  Future<Message> _sendMessage(
    stream.Channel streamChannel,
    String text, {
    String? quoteId,
  }) async {
    final message = stream.Message(text: text, quotedMessageId: quoteId);

    // Message id was generated when message was created, so no need to await
    streamChannel.sendMessage(
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

  Stream<RequestProgress> _uploadFile(
    stream.Channel channel,
    String filePath, {
    String? title,
    String? description,
  }) {
    final progress = StreamController<RequestProgress>();

    File(filePath).length().then((size) {
      final attachmentFile = stream.AttachmentFile(
        size: size,
        path: filePath,
      );
      return channel.sendFile(
        attachmentFile,
        onSendProgress: (count, total) {
          progress.add(RequestProgress(current: count, total: total));
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

      return channel.sendMessage(
        message,
        skipPush: true,
      );
    }).then((_) => progress.close());

    return progress.stream;
  }

  Future<void> _updateChannelData(
      stream.Channel channel, ChannelData data) async {
    await channel.updatePartial(set: data.toJson());
  }

  Future<AgoraChannelDataPayload> getAgoraChannelData(String channelId) async {
    final callResponse = await _client.createCall(
      callId: channelId,
      callType: 'audio',
      channelType: 'livestream',
      channelId: channelId,
    );
    final call = callResponse.call!;

    final tokenResponse = await _client.getCallToken(call.id);

    return (
      channelId: call.agora!.channel,
      userId: tokenResponse.agoraUid!,
      token: tokenResponse.token!,
    );
  }
}
