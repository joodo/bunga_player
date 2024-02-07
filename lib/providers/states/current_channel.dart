// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/services/stream_io.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

const videoTypeChannelDataKey = 'video_type';

class CurrentChannel extends ChangeNotifier {
  CurrentChannel(this._context);
  final BuildContext _context;

  Channel? _channel;
  bool get isEmpty => _channel == null;

  final _watchersNotifier = ValueNotifier<List<User>>([]);
  late final watchersNotifier = _watchersNotifier.createReadonly();

  final channelDataNotifier = ValueNotifier<ChannelData?>(null);

  User? _lastChannelDataUpdater;
  User? get lastChannelDataUpdater => _lastChannelDataUpdater;

  // Streams
  Stream<Message?> get messageStream =>
      _channel?.on('message.new').map((event) => event.message) ??
      const Stream.empty();
  Stream<User> get watcherJoinEventStream =>
      _channel?.on('user.watching.start').map((event) => event.user!) ??
      const Stream.empty();
  Stream<User> get watcherLeaveEventStream =>
      _channel?.on('user.watching.stop').map((event) => event.user!) ??
      const Stream.empty();

  final List<StreamSubscription> _streamSubscriptions = [];

  Future<void> createOrJoin(ChannelData data) async {
    if (_channel != null) await leave();
    assert(_channel == null);

    final chatService = getService<StreamIO>();
    _channel = await chatService.createOrJoinChannelByData(data);

    await _setUpChannel();

    notifyListeners();
  }

  Future<void> joinById(String id) async {
    if (_channel != null) await leave();
    assert(_channel == null);

    final chatService = getService<StreamIO>();
    _channel = await chatService.joinChannelById(id);

    await _setUpChannel();

    notifyListeners();
  }

  Future<void> leave() async {
    assert(_channel != null);

    for (final subscription in _streamSubscriptions) {
      await subscription.cancel();
    }
    _streamSubscriptions.clear();

    final chatService = getService<StreamIO>();
    await chatService.leaveChannel(_channel!);

    _channel = null;
    channelDataNotifier.value = null;
    _watchersNotifier.value = [];
    _lastChannelDataUpdater = null;

    notifyListeners();
  }

  bool _isCurrentUser(User user) => _context.read<CurrentUser>().id == user.id;

  Future<void> _onUserJoin(User user) async {
    if (_isCurrentUser(user)) return;

    final chatService = getService<StreamIO>();
    // user name won't update if he renamed recently
    user = (await chatService.updateUsers([user])).first;

    _watchersNotifier.value = List.from(_watchersNotifier.value)..add(user);

    getService<Toast>().show('${user.name} 已加入');
    AudioPlayer().play(AssetSource('sounds/user_join.wav'));
  }

  void _onUserLeave(User user) {
    _watchersNotifier.value = List.from(_watchersNotifier.value)
      ..removeWhere((u) {
        if (u.id == user.id) {
          getService<Toast>().show('${u.name} 已离开');
          AudioPlayer().play(AssetSource('sounds/user_leave.wav'));
          return true;
        } else {
          return false;
        }
      });
  }

  Future<void> _setUpChannel() async {
    assert(_channel != null);

    // HACK: watchers won't auto query
    await _channel!.query(
      watch: true,
      // watchers won't query if no pagination
      watchersPagination: const PaginationParams(limit: 1000),
    );

    final chatService = getService<StreamIO>();
    // user name won't update if he renamed recently
    _watchersNotifier.value =
        await chatService.updateUsers(_channel!.state!.watchers);

    // Set up streams event
    _streamSubscriptions.addAll([
      messageStream.listen((message) {
        logger
            .i('Receive message from ${message!.user!.name}: ${message.text}');
      }),
      watcherJoinEventStream.listen(_onUserJoin),
      watcherLeaveEventStream.listen(_onUserLeave),
      _channel!
          .on('channel.updated')
          .map((event) => event.user!)
          .listen((user) {
        logger.i('${user.name} changed channel data');
        if (_isCurrentUser(user)) return;
        getService<Toast>().show('${user.name} 更换了影片');
        _lastChannelDataUpdater = user;
      }),
      _channel!.extraDataStream
          .map<ChannelData?>((jsonData) => ChannelData.fromJson(jsonData))
          .listen((channelData) => channelDataNotifier.value = channelData),
    ]);
  }

  Future<void> send(Message message) async {
    assert(_channel != null);
    logger.i('Send message: $message');
    await _channel!.sendMessage(message);
  }

  Future updateData(ChannelData data) async {
    assert(_channel != null);
    await _channel!.updatePartial(set: data.toJson());
  }

  Future<VoiceCallChannelData> createVoiceCall() async {
    assert(_channel != null);

    final chatService = getService<StreamIO>();
    return await chatService.createVoiceCall(_channel!.id!);
  }

  @override
  String toString() {
    return 'id: ${_channel?.cid}\ndata: ${channelDataNotifier.value.toString()}';
  }
}
