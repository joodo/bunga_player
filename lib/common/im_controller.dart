import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/common/logger.dart';
import 'package:bunga_player/common/snack_bar.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/secrets/secrets.dart';
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
  }

  final _chatClient = StreamChatClient(
    StreamKey.appKey,
    logLevel: Level.WARNING,
  );

  OwnUser? _user;
  User? get currentUser => _user;
  String? get userName => _user?.name;

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
  final List<int> _callChannelUsers = [];

  void _setupVoiceSDKEngine() async {
    try {
      await [Permission.microphone].request();
    } catch (e) {
      logger.e(e);
    }

    await _agoraEngine
        .initialize(const RtcEngineContext(appId: AgoraKey.appID));
    _agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          logger.i("Local user uid:${connection.localUid} joined the channel");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          logger.i("Remote user uid:$remoteUid joined the voice channel");
          if (connection.localUid != remoteUid) {
            _callChannelUsers.add(remoteUid);
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          _callChannelUsers.remove(remoteUid);
          logger.i(
              "Remote user uid:$remoteUid left the channel\nUser remain: $_callChannelUsers");
          if (_callChannelUsers.isEmpty) {
            showSnackBar('对方已挂断');
            hangUpCall();
          }
        },
      ),
    );
  }

  Future<bool> login(String userName) async {
    try {
      final userID = userName.hashCode.toString();
      _user = await _chatClient.connectUser(
        User(
          id: userID,
          name: userName,
        ),
        _chatClient.devToken(userID).rawValue,
      );
    } catch (e) {
      logger.e(e);
      return false;
    }
    logger.i('Current user: ${_user?.name}');
    return true;
  }

  Future<bool> logout() async {
    try {
      await _chatClient.disconnectUser();
    } catch (e) {
      logger.e(e);
      return false;
    }
    return true;
  }

  Channel? _channel;
  final _channelWatchers = ChannelWatchers();
  ChannelWatchers get channelWatchers => _channelWatchers;
  Future<bool> createOrJoinGroup(String channelID, String channelName) async {
    _channel = _chatClient.channel(
      'livestream',
      id: channelID,
      extraData: {
        'name': channelName,
      },
    );

    try {
      await _channel!.watch();
      await _channelWatchers.queryFromChannel(_channel!);
    } catch (e) {
      logger.e(e);
      return false;
    }

    if (_channelWatchers.watchers!.length > 1) {
      _askPosition();
    }

    _channel!.on('message.new').listen(_onNewMessage);
    _channel!.on('user.watching.start').listen((event) {
      if (event.user!.id == _user!.id) return;
      if (_channelWatchers.addUser(event.user!)) {
        showSnackBar('${event.user!.name} 已加入');
        AudioPlayer().play(AssetSource('sounds/user_join.wav'));
      }
    });
    _channel!.on('user.watching.stop').listen((event) {
      _channelWatchers.removeUser(event.user!);
      showSnackBar('${event.user!.name} 已离开');
      AudioPlayer().play(AssetSource('sounds/user_leave.wav'));

      // Someone leave when I'm asking call, means he rejects me
      if (callStatus.value == CallStatus.callOut) {
        _myCallAskingIsRejectedBy(event.user!);
      }
    });

    return true;
  }

  /// return message id
  Future<String?> sendMessage(Message m) async {
    try {
      final response = await _channel!.sendMessage(m);
      return response.message.id;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  String? _askID;
  Future<bool> _askPosition() async {
    _askID = await sendMessage(Message(text: 'where'));
    if (_askID == null) return false;

    Future.delayed(const Duration(seconds: 6), () {
      logger.w('Asked position but no one answered');
      _askID = null;
    });

    return true;
  }

  Future<bool> sendPlayerStatus({String? quoteMessageId}) async {
    if (_applyingStatus) return true;

    final isPlay = VideoController().isPlaying.value;
    final position = VideoController().position.value;

    final messageText =
        '${isPlay ? "play" : "pause"} at ${position.inMilliseconds}';
    final messageID = await sendMessage(Message(
      text: messageText,
      quotedMessageId: quoteMessageId,
    ));
    return messageID != null;
  }

  // If applying status from remote, then don't send self status to remote
  bool _applyingStatus = false;

  void _onNewMessage(Event event) {
    logger
        .i('Reeceive message from ${event.user?.name}: ${event.message?.text}');

    final userID = event.user!.id;
    if (userID == _user!.id) return;

    final re = event.message!.text!.split(' ');

    void applyStatus() async {
      _applyingStatus = true;

      bool canShowSnackBar = true;
      // If apply status is because asking where, then don't show snack bar
      if (_askID != null) canShowSnackBar = false;

      final isPlaying = VideoController().isPlaying.value;
      if (re.first == 'pause' && isPlaying) {
        VideoController().isPlaying.value = false;
        if (canShowSnackBar) {
          showSnackBar('${event.user!.name} 暂停了视频');
          canShowSnackBar = false;
        }
      }
      if (re.first == 'play' && !isPlaying) {
        VideoController().isPlaying.value = true;
        if (canShowSnackBar) {
          showSnackBar('${event.user!.name} 播放了视频');
          canShowSnackBar = false;
        }
      }

      final position = VideoController().position.value;
      final remotePosition = Duration(milliseconds: int.parse(re.last));
      if ((position - remotePosition).inMilliseconds.abs() > 1000) {
        VideoController().jumpTo(remotePosition);
        if (canShowSnackBar) {
          showSnackBar('${event.user!.name} 调整了进度');
          canShowSnackBar = false;
        }
      }
    }

    if (re.first == 'where') {
      sendPlayerStatus(quoteMessageId: event.message!.id);
      return;
    }

    if (re.first == 'play' || re.first == 'pause') {
      final quoteID = event.message!.quotedMessageId;
      if (quoteID != null) {
        if (quoteID != _askID) return;

        applyStatus();
        _askID = null;
      } else {
        applyStatus();
      }

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
      _myCallAskingHopeList!.remove(_user!.id);
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
      callId: _channel!.id!,
      callType: 'audio',
      channelType: _channel!.type,
      channelId: _channel!.id!,
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
