import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/services/tokens.dart';
import 'package:bunga_player/utils/stream_proxy.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class Chat {
  // Singleton
  static final _instance = Chat._internal();
  factory Chat() => _instance;

  Chat._internal() {
    messageStream.listen((message) {
      logger.i('Receive message from ${message!.user!.name}: ${message.text}');
    });
    watcherLeaveEventStream.listen((user) {
      _watchersNotifier.value = List.from(_watchersNotifier.value)
        ..removeWhere((u) => u.id == user.id);
      showSnackBar('${user.name} 已离开');
      AudioPlayer().play(AssetSource('sounds/user_leave.wav'));
    });
    watcherJoinEventStream.listen((user) {
      if (_watchersNotifier.value.firstWhereOrNull((u) => u.id == user.id) !=
          null) {
        return;
      }

      _watchersNotifier.value = List.from(_watchersNotifier.value)..add(user);
      showSnackBar('${user.name} 已加入');
      AudioPlayer().play(AssetSource('sounds/user_join.wav'));
    });
    channelUpdateEventStream.listen((event) {
      logger.i(
          'remote change room data: ${event?.channel?.extraData.toString()}');

      final user = event!.user;
      if (user == null || user.id == Chat().currentUserNotifier.value?.id) {
        return;
      }
      showSnackBar('${user.name} 更换了影片');
    });

    channelExtraDataNotifier.bind(_channelExtraData.stream);
  }

  late final StreamChatClient _chatClient;
  void init() {
    _chatClient = StreamChatClient(
      Tokens().streamIO.appKey,
      logLevel: Level.WARNING,
    );
  }

  // User
  final _currentUserNotifier = ValueNotifier<User?>(null);
  late final currentUserNotifier = _currentUserNotifier.readonly;

  Future<void> login(String userName) async {
    _currentUserNotifier.value = await _chatClient.connectUser(
      User(
        id: Tokens().bunga.clientID,
        name: userName,
      ),
      Tokens().streamIO.userToken,
    );

    logger.i('Current user: ${currentUserNotifier.value!.name}');
  }

  Future<void> logout() async {
    await _chatClient.disconnectUser();
    _currentUserNotifier.value = null;
  }

  // Channel
  final _currentChannelNotifier = ValueNotifier<Channel?>(null);
  late final currentChannelNotifier = _currentChannelNotifier.readonly;

  final _messageStream = StreamProxy<Message?>.broadcast();
  late final messageStream = _messageStream.stream;

  final _watcherLeaveEventStream = StreamProxy<User>.broadcast();
  late final watcherLeaveEventStream = _watcherLeaveEventStream.stream;
  final _watcherJoinEventStream = StreamProxy<User>.broadcast();
  late final watcherJoinEventStream = _watcherJoinEventStream.stream;

  final _watchersNotifier = ValueNotifier<List<User>>([]);
  late final watchersNotifier = _watchersNotifier.readonly;

  final _channelUpdateEventStream = StreamProxy<Event?>.broadcast();
  late final channelUpdateEventStream = _channelUpdateEventStream.stream;
  final _channelExtraData = StreamProxy<Map<String, Object?>>();
  final channelExtraDataNotifier =
      ReadonlyStreamNotifier<Map<String, Object?>>({});

  Future<void> createOrJoinRoomByHash(
    String hash, {
    Map<String, Object?>? extraData,
  }) async {
    Channel channel;

    for (int suffix = 0; true; suffix++) {
      final id = suffix == 0 ? hash : '$hash-$suffix';
      channel = _chatClient.channel(
        'livestream',
        // Unique id
        id: id,
        extraData: extraData,
      );

      final state = await channel.query();
      if (state.channel?.extraData['hash'] == hash) break;

      logger.i(
          'Channel id $id was changed hash to ${state.channel?.extraData['hash']}, try next one.');
    }

    await channel.watch();
    await _setUpChannel(channel);
  }

  Future<void> joinRoomById(String id) async {
    final channel = _chatClient.channel(
      'livestream',
      id: id,
    );
    await channel.watch();
    await _setUpChannel(channel);
  }

  Future<void> _setUpChannel(Channel channel) async {
    _currentChannelNotifier.value = channel;

    // watchers won't auto query
    await channel.query(
      watch: true,
      // watchers won't query if no pagination
      watchersPagination: const PaginationParams(limit: 1000),
    );

    _messageStream.source =
        channel.on('message.new').map((event) => event.message);
    _watcherJoinEventStream.source =
        channel.on('user.watching.start').map((event) => event.user!);
    _watcherLeaveEventStream.source =
        channel.on('user.watching.stop').map((event) => event.user!);
    _channelUpdateEventStream.source = channel.on('channel.updated');

    _watchersNotifier.value = channel.state!.watchers;
    _channelExtraData.source = channel.extraDataStream;
  }

  Future<void> leaveRoom() async {
    await currentChannelNotifier.value!.stopWatching();
    _currentChannelNotifier.value = null;

    _messageStream.source = null;
    _watcherJoinEventStream.source = null;
    _watcherLeaveEventStream.source = null;
    _channelUpdateEventStream.source = null;
    _channelExtraData.source = Stream.value({});

    _watchersNotifier.value = [];
  }

  /// Return message id
  Future<String?> sendMessage(Message m) async {
    try {
      final response = await currentChannelNotifier.value!.sendMessage(m);
      return response.message.id;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<void> updateChannelData(Map<String, dynamic> data) async {
    await currentChannelNotifier.value!.updatePartial(set: data);
  }

  Future<List<Channel>> fetchBiliChannels() async {
    final filter = Filter.equal('video_type', 'bilibili');
    final channels = await _chatClient
        .queryChannels(
          filter: filter,
          channelStateSort: [
            const SortOption('last_message_at', direction: SortOption.DESC)
          ],
          watch: false,
          state: false,
        )
        .last;
    return channels;
  }

  Future<Map<String, dynamic>> createVoiceCall() async {
    final callResponse = await _chatClient.createCall(
      callId: currentChannelNotifier.value!.id!,
      callType: 'audio',
      channelType: currentChannelNotifier.value!.type,
      channelId: currentChannelNotifier.value!.id!,
    );
    final call = callResponse.call!;

    final tokenResponse = await _chatClient.getCallToken(call.id);

    return {
      'token': tokenResponse.token!,
      'channelId': call.agora!.channel,
      'uid': tokenResponse.agoraUid!,
    };
  }
}
