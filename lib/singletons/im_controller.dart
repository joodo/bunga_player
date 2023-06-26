import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/singletons/im_video_connector.dart';
import 'package:bunga_player/singletons/logger.dart';
import 'package:bunga_player/singletons/popmoji_controller.dart';
import 'package:bunga_player/singletons/snack_bar.dart';
import 'package:bunga_player/constants/secrets.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:collection/collection.dart';

enum CallStatus {
  none,
  callIn,
  callOut,
  calling,
}

class IMController {
  // Singleton
  static final _instance = IMController._internal();
  factory IMController() => _instance;

  IMController._internal() {
    // Agora
    _setupVoiceSDKEngine();
  }

  void dispose() async {
    await _agoraEngine.leaveChannel();
    await _agoraEngine.release();
  }

  final _chatClient = StreamChatClient(
    StreamKey.appKey,
    logLevel: Level.WARNING,
  );

  final currentUserNotifier = ValueNotifier<User?>(null);

  // for call
  final _agoraEngine = createAgoraRtcEngine();
  final callStatus = ValueNotifier<CallStatus>(CallStatus.none);
  String? _callAskingMessageId;
  List<String>? _myCallAskingHopeList;
  late final _callAskingTimeOutTimer = RestartableTimer(
    const Duration(seconds: 30),
    () {
      showSnackBar('无人接听');
      cancelCallAsking();
    },
  )..cancel();
  final Set<int> _callChannelUsers = {};

  void _setupVoiceSDKEngine() async {
    try {
      await [Permission.microphone].request();
    } catch (e) {
      logger.e(e);
    }

    await _agoraEngine.initialize(const RtcEngineContext(
      appId: AgoraKey.appID,
      logConfig: LogConfig(level: LogLevel.logLevelWarn),
    ));
    _agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          logger.i("Voice call: Local user uid:${connection.localUid} joined.");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          logger.i("Voice call: Remote user uid:$remoteUid joined.");
          if (connection.localUid != remoteUid) {
            _callChannelUsers.add(remoteUid);
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          _callChannelUsers.remove(remoteUid);
          logger.i(
              "Voice call: Remote user uid:$remoteUid left.\nUser remain: $_callChannelUsers");
          if (_callChannelUsers.isEmpty) {
            showSnackBar('对方已挂断');
            hangUpCall();
          }
        },
      ),
    );
  }

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
  Channel? _currentChannel;
  Channel? get currentChannel => _currentChannel;

  final _channelWatchers = ChannelWatchers();
  ChannelWatchers get channelWatchers => _channelWatchers;

  final channelUpdateEventNotifier = ProxyValueNotifier<Event?, Event>(
    initialValue: null,
    proxy: (event) => event,
  );

  final _channelEventSubscribes = <StreamSubscription<Event>>[];

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
        id: hash,
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
    _currentChannel = channel;

    await _currentChannel!.watch();
    await _channelWatchers.queryFromChannel(_currentChannel!);

    _channelEventSubscribes.addAll([
      _currentChannel!.on('message.new').listen(_onNewMessage),
      _currentChannel!.on('user.watching.start').listen(_onUserJoin),
      _currentChannel!.on('user.watching.stop').listen(_onUserLeave),
    ]);
    channelUpdateEventNotifier.from = StreamNotifier<Event>(
      initialValue: Event(
        user: currentUserNotifier.value,
        channel: EventChannel(
          cid: _currentChannel!.cid!,
          config: _currentChannel!.config!,
          createdAt: _currentChannel!.createdAt!,
          updatedAt: _currentChannel!.updatedAt!,
          extraData: _currentChannel!.extraData,
        ),
      ),
      stream: _currentChannel!.on('channel.updated'),
    );
  }

  Future<void> leaveRoom() async {
    await _currentChannel!.stopWatching();

    for (var subscribe in _channelEventSubscribes) {
      subscribe.cancel();
    }
    _channelEventSubscribes.clear();

    _channelWatchers.clear();

    _currentChannel = null;

    channelUpdateEventNotifier.from = null;

    hangUpCall();
  }

  /// return message id
  Future<String?> sendMessage(Message m) async {
    try {
      final response = await _currentChannel!.sendMessage(m);
      return response.message.id;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  void _onNewMessage(Event event) {
    logger
        .i('Receive message from ${event.user?.name}: ${event.message?.text}');

    final re = event.message!.text!.split(' ');
    if (re.first == 'popmoji') {
      PopmojiController().receive(re[1]);
    }

    final userID = event.user!.id;
    if (userID == currentUserNotifier.value!.id) return;

    if (re.first == 'where') {
      IMVideoConnector().answerPlayStatus(event);
      return;
    }

    if (re.first == 'play' || re.first == 'pause') {
      IMVideoConnector().processPlayStatus(event);
      return;
    }

    if (re.first == 'call') {
      if (re[1] == 'ask') {
        switch (callStatus.value) {
          // Has call in
          case CallStatus.none:
            callStatus.value = CallStatus.callIn;
            _callAskingMessageId = event.message!.id;
            break;

          // Already has call in, no need to deal, current caller will answer
          case CallStatus.callIn:
            break;

          // Some one also want call when I'm calling out, so answer him
          case CallStatus.callOut:
            final m = Message(
              text: 'call yes',
              quotedMessageId: event.message!.id,
            );
            sendMessage(m).then((messgeID) {
              if (messgeID != null) _myCallAskingHasBeenAccepted();
            });
            break;

          // Some one want to join when we are calling, answer him
          case CallStatus.calling:
            final m = Message(
              text: 'call yes',
              quotedMessageId: event.message!.id,
            );
            sendMessage(m);
            break;
        }
        return;
      }

      // caller canceled asking
      if (re[1] == 'cancel') {
        if (callStatus.value == CallStatus.callIn &&
            event.message!.quotedMessageId == _callAskingMessageId) {
          callStatus.value = CallStatus.none;
          _callAskingMessageId = null;
        }
        return;
      }

      // if not asking or cancel asking, then should be yes or no.
      // then if I'm not asking, or he's not answering me, ignore it.
      if (callStatus.value != CallStatus.callOut ||
          event.message!.quotedMessageId != _callAskingMessageId) return;

      // someone answer me yes
      if (re[1] == 'yes') {
        _myCallAskingHasBeenAccepted();
      }

      // someone rejected me
      if (re[1] == 'no') {
        _myCallAskingIsRejectedBy(event.user!);
      }
    }
  }

  void _onUserJoin(Event event) {
    final user = event.user!;
    if (user.id == currentUserNotifier.value!.id) return;
    if (_channelWatchers.addUser(user)) {
      showSnackBar('${user.name} 已加入');
      AudioPlayer().play(AssetSource('sounds/user_join.wav'));
    }
  }

  void _onUserLeave(Event event) {
    final user = event.user!;
    _channelWatchers.removeUser(user);
    showSnackBar('${user.name} 已离开');
    AudioPlayer().play(AssetSource('sounds/user_leave.wav'));

    // Someone leave when I'm asking call, means he rejects me
    if (callStatus.value == CallStatus.callOut) {
      _myCallAskingIsRejectedBy(user);
    }
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

  void _myCallAskingHasBeenAccepted() {
    callStatus.value = CallStatus.calling;
    _callAskingMessageId = null;
    _myCallAskingHopeList = null;
    _callAskingTimeOutTimer.cancel();

    _joinCallChannel();
  }

  void _myCallAskingIsRejectedBy(User user) {
    _myCallAskingHopeList!.remove(user.id);
    logger.i(
        '${user.id} rejected call asking or leaved, hope list: $_myCallAskingHopeList');
    if (_myCallAskingHopeList!.isEmpty) {
      showSnackBar('呼叫已被拒绝');
      cancelCallAsking();
    }
  }

  void startCallAsking() async {
    callStatus.value = CallStatus.callOut;
    var message = Message(text: 'call ask');
    _callAskingMessageId = await sendMessage(message);

    if (_callAskingMessageId != null) {
      _myCallAskingHopeList =
          _channelWatchers.watchers!.map((e) => e.id).toList();
      _myCallAskingHopeList!.remove(currentUserNotifier.value!.id);
      logger.i('start call asking, hope list: $_myCallAskingHopeList');

      _callAskingTimeOutTimer.reset();
    } else {
      callStatus.value = CallStatus.none;
    }
  }

  void cancelCallAsking() {
    sendMessage(Message(
      text: 'call cancel',
      quotedMessageId: _callAskingMessageId,
    ));
    _myCallAskingHopeList = null;
    _callAskingMessageId = null;
    callStatus.value = CallStatus.none;
    _callAskingTimeOutTimer.cancel();
  }

  void rejectCallAsking() {
    sendMessage(Message(
      text: 'call no',
      quotedMessageId: _callAskingMessageId,
    ));
    _callAskingMessageId = null;
    callStatus.value = CallStatus.none;
  }

  void acceptCallAsking() {
    sendMessage(Message(
      text: 'call yes',
      quotedMessageId: _callAskingMessageId,
    ));
    _callAskingMessageId = null;
    callStatus.value = CallStatus.calling;

    try {
      _joinCallChannel();
    } catch (e) {
      logger.e(e);
      callStatus.value = CallStatus.none;
    }
  }

  void hangUpCall() {
    if (callStatus.value == CallStatus.none) return;
    callStatus.value = CallStatus.none;
    AudioPlayer().play(AssetSource('sounds/hang_up.wav'));
    _leaveCallChannel();
  }

  // range 0 ~ 400
  void setVoiceVolume(int volume) async {
    assert(volume >= 0 && volume <= 400);
    await _agoraEngine.adjustPlaybackSignalVolume(volume);
  }

  void _joinCallChannel() async {
    final callResponse = await _chatClient.createCall(
      callId: _currentChannel!.id!,
      callType: 'audio',
      channelType: _currentChannel!.type,
      channelId: _currentChannel!.id!,
    );
    final call = callResponse.call!;

    final tokenResponse = await _chatClient.getCallToken(call.id);

    const options = ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    logger.i('''try join voice channel
    token: ${tokenResponse.token!}
    channelId: ${call.agora!.channel}
    uid: ${tokenResponse.agoraUid!}
    ''');
    await _agoraEngine.joinChannel(
      token: tokenResponse.token!,
      channelId: call.agora!.channel,
      uid: tokenResponse.agoraUid!,
      options: options,
    );
  }

  void _leaveCallChannel() {
    _agoraEngine.leaveChannel();
  }
}

class ChannelWatchers extends ChangeNotifier {
  List<User>? _watchers;
  List<User>? get watchers => _watchers;

  Future<void> queryFromChannel(Channel channel) async {
    final result = await channel.query(
      watch: true,
      watchersPagination: const PaginationParams(limit: 100, offset: 0),
    );
    _watchers = result.watchers!;
    notifyListeners();
  }

  void clear() {
    _watchers = null;
    notifyListeners();
  }

  void removeUser(User user) {
    _watchers?.removeWhere((element) => element.id == user.id);
    notifyListeners();
  }

  // return false if user already exist
  bool addUser(User user) {
    if (_watchers == null ||
        _watchers!.firstWhereOrNull((watcher) => watcher.id == user.id) !=
            null) {
      return false;
    }
    _watchers!.add(user);
    notifyListeners();
    return true;
  }

  String toStringExcept(User exceptUser) {
    if (_watchers == null) return '';

    String result = '';
    for (var user in _watchers!) {
      if (user.id == exceptUser.id) continue;
      result += '${user.name}, ';
    }

    try {
      result = result.substring(0, result.length - 2);
    } catch (e) {
      return '';
    }

    return result;
  }
}
