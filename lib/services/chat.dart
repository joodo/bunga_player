import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/constants/secrets.dart';
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
    // HACK: for late lazy load
    watcherJoinEventStream;
  }

  final _chatClient = StreamChatClient(
    StreamKey.appKey,
    logLevel: Level.WARNING,
  );

  // User
  final currentUserNotifier = ValueNotifier<User?>(null);

  Future<void> login(String userName) async {
    final userID = userName.hashCode.toString();
    currentUserNotifier.value = await _chatClient.connectUser(
      User(
        id: userID,
        name: userName,
      ),
      _chatClient.devToken(userID).rawValue,
    );

    logger.i('Current user: ${currentUserNotifier.value!.name}');
  }

  Future<void> logout() async {
    await _chatClient.disconnectUser();
    currentUserNotifier.value = null;
  }

  // Channel
  final currentChannelNotifier = ValueNotifier<Channel?>(null);

  final _messageStream = StreamProxy<Message?>.broadcast();
  late final messageStream = _messageStream.stream
    ..listen((message) {
      logger.i('Receive message from ${message!.user!.name}: ${message.text}');
    });

  final _watcherLeaveEventStream = StreamProxy<User>.broadcast();
  late final watcherLeaveEventStream = _watcherLeaveEventStream.stream
    ..listen((user) {
      _watchersNotifier.value = List.from(_watchersNotifier.value)
        ..removeWhere((u) => u.id == user.id);
      showSnackBar('${user.name} 已离开');
      AudioPlayer().play(AssetSource('sounds/user_leave.wav'));
    });
  final _watcherJoinEventStream = StreamProxy<User>.broadcast();
  late final watcherJoinEventStream = _watcherJoinEventStream.stream
    ..listen((user) {
      if (_watchersNotifier.value.firstWhereOrNull((u) => u.id == user.id) !=
          null) {
        return;
      }

      _watchersNotifier.value = List.from(_watchersNotifier.value)..add(user);
      showSnackBar('${user.name} 已加入');
      AudioPlayer().play(AssetSource('sounds/user_join.wav'));
    });

  final _watchersNotifier = PrivateValueNotifier<List<User>>([]);
  late final watchersNotifier = _watchersNotifier.readonly;

  final _channelUpdateEventStream = StreamProxy<Event?>.broadcast();
  late final channelUpdateEventStream = _channelUpdateEventStream.stream
    ..listen((event) {
      logger.i(
          'remote change room data: ${event?.channel?.extraData.toString()}');

      final user = event!.user;
      if (user == null || user.id == Chat().currentUserNotifier.value?.id) {
        return;
      }
      showSnackBar('${user.name} 更换了影片');
    });
  final _channelExtraData = StreamProxy<Map<String, Object?>>();
  late final channelExtraDataNotifier = StreamNotifier<Map<String, Object?>>(
    initialValue: {},
    stream: _channelExtraData.stream,
  );

  Future<void> createOrJoinRoomByHash(
    String hash, {
    Map<String, Object?>? extraData,
  }) async {
    final filter = Filter.equal('hash', hash);
    final channels = await _chatClient.queryChannels(
      filter: filter,
      channelStateSort: [
        const SortOption('last_message_at', direction: SortOption.DESC)
      ],
    ).last;

    if (channels.isNotEmpty) {
      // join exist channel
      await _setUpChannel(channels.first);
    } else {
      // create channel
      await _setUpChannel(_chatClient.channel(
        'livestream',
        // Unique id
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        extraData: extraData,
      ));
    }
  }

  Future<void> joinRoomById(String id) async {
    await _setUpChannel(_chatClient.channel(
      'livestream',
      id: id,
    ));
  }

  Future<void> _setUpChannel(Channel channel) async {
    currentChannelNotifier.value = channel;
    await channel.watch();
    // watchers won't auto query
    await channel.query(
      watch: true,
      // watchers won't query if no pagination
      watchersPagination: const PaginationParams(limit: 1000),
    );

    _messageStream.setSourceStream(
        channel.on('message.new').map((event) => event.message));
    _watcherJoinEventStream.setSourceStream(
        channel.on('user.watching.start').map((event) => event.user!));
    _watcherLeaveEventStream.setSourceStream(
        channel.on('user.watching.stop').map((event) => event.user!));
    _channelUpdateEventStream.setSourceStream(channel.on('channel.updated'));

    _watchersNotifier.value = channel.state!.watchers;

    _channelExtraData.setSourceStream(channel.extraDataStream);
    // wait notifier update
    // HACK: remove this will cause channelExtraDataNotifier keep null, why?!
    channelExtraDataNotifier.value;
    await Future.delayed(Duration.zero);
  }

  Future<void> leaveRoom() async {
    await currentChannelNotifier.value!.stopWatching();
    currentChannelNotifier.value = null;

    _messageStream.setEmpty();
    _watcherJoinEventStream.setEmpty();
    _watcherLeaveEventStream.setEmpty();
    _channelUpdateEventStream.setEmpty();
    _channelExtraData.setSourceStream(Stream.value({}));

    _watchersNotifier.value = [];
  }

  /// Return message id
  Future<String?> sendMessage(Message m) async {
    try {
      logger.i('Send message: ${m.text}');
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
