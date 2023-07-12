import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/services/tokens.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

enum CallStatus {
  none,
  callIn,
  callOut,
  calling,
}

class VoiceCall {
  // Singleton
  static final _instance = VoiceCall._internal();
  factory VoiceCall() => _instance;

  VoiceCall._internal() {
    _setUpBindings();

    _loadSavedVolume();
  }

  void _setUpBindings() {
    volume.addListener(() {
      mute.value = false;
      _setVolume(volume.value);
      Preferences().set('call_volume', volume.value);
    });
    mute.addListener(
      () {
        mute.value ? _setVolume(0) : _setVolume(volume.value);
      },
    );

    callStatusNotifier.addListener(() {
      // Play sound when call in or out
      if (_callStatus.value == CallStatus.callIn ||
          _callStatus.value == CallStatus.callOut) {
        _callRinger.resume();
      } else {
        _callRinger.stop();
      }
    });

    Chat().currentChannelNotifier.addListener(() {
      if (Chat().currentChannelNotifier.value == null) {
        // Hang up if leave room
        hangUp();
      }
    });

    Chat().watcherLeaveEventStream.listen((user) {
      // Someone left when I'm asking call, means he rejected me
      if (callStatusNotifier.value == CallStatus.callOut) {
        _myCallAskingIsRejectedBy(user);
      }
    });

    Chat()
        .messageStream
        .where((message) => message?.text?.split(' ').first == 'call')
        .listen((message) {
      if (message!.user?.id == Tokens().bunga.clientID) {
        return;
      }

      final content = message.text?.split(' ')[1];
      switch (content) {
        // someone ask for call
        case 'ask':
          switch (callStatusNotifier.value) {
            // Has call in
            case CallStatus.none:
              _callStatus.value = CallStatus.callIn;
              _callAskingMessageId = message.id;
              break;

            // Already has call in, no need to deal, current caller will answer
            case CallStatus.callIn:
              break;

            // Some one also want call when I'm calling out, so answer him
            case CallStatus.callOut:
              final m = Message(
                text: 'call yes',
                quotedMessageId: message.id,
              );
              Chat().sendMessage(m).then((messgeID) {
                if (messgeID != null) _myCallAskingHasBeenAccepted();
              });
              break;

            // Some one want to join when we are calling, answer him
            case CallStatus.calling:
              final m = Message(
                text: 'call yes',
                quotedMessageId: message.id,
              );
              Chat().sendMessage(m);
              break;
          }
          break;

        // caller canceled asking
        case 'cancel':
          if (callStatusNotifier.value == CallStatus.callIn &&
              message.quotedMessageId == _callAskingMessageId) {
            _callStatus.value = CallStatus.none;
            _callAskingMessageId = null;
          }
          break;

        case 'yes':
          if (callStatusNotifier.value == CallStatus.callOut &&
              message.quotedMessageId == _callAskingMessageId) {
            _myCallAskingHasBeenAccepted();
          }
          break;

        case 'no':
          if (callStatusNotifier.value == CallStatus.callOut &&
              message.quotedMessageId == _callAskingMessageId) {
            _myCallAskingIsRejectedBy(message.user!);
          }
          break;

        default:
          logger.w('Unknown call message: $content');
      }
    });
  }

  final _agoraEngine = createAgoraRtcEngine();
  final _callChannelUsers = <int>{};
  Future<void> init() async {
    // Mic permission
    /*
    try {
      await [Permission.microphone].request();
    } catch (e) {
      logger.e(e);
    }
    */

    // Engine
    await _agoraEngine.initialize(RtcEngineContext(
      appId: Tokens().agora.appKey,
      logConfig: const LogConfig(level: LogLevel.logLevelWarn),
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
            hangUp();
          }
        },
      ),
    );
  }

  final _callStatus = ValueNotifier<CallStatus>(CallStatus.none);
  late final callStatusNotifier = _callStatus.createReadonly();

  void startAsking() async {
    _callStatus.value = CallStatus.callOut;
    var message = Message(text: 'call ask');
    _callAskingMessageId = await Chat().sendMessage(message);

    if (_callAskingMessageId != null) {
      _myCallAskingHopeList = Chat()
          .currentChannelNotifier
          .value!
          .state!
          .watchers
          .map((e) => e.id)
          .toList();
      _myCallAskingHopeList!.remove(Tokens().bunga.clientID);
      logger.i('start call asking, hope list: $_myCallAskingHopeList');

      _callAskingTimeOutTimer.reset();
    } else {
      _callStatus.value = CallStatus.none;
    }
  }

  void cancelAsking() {
    Chat().sendMessage(Message(
      text: 'call cancel',
      quotedMessageId: _callAskingMessageId,
    ));
    _myCallAskingHopeList = null;
    _callAskingMessageId = null;
    _callStatus.value = CallStatus.none;
    _callAskingTimeOutTimer.cancel();
  }

  void rejectAsking() {
    Chat().sendMessage(Message(
      text: 'call no',
      quotedMessageId: _callAskingMessageId,
    ));
    _callAskingMessageId = null;
    _callStatus.value = CallStatus.none;
  }

  void acceptAsking() {
    Chat().sendMessage(Message(
      text: 'call yes',
      quotedMessageId: _callAskingMessageId,
    ));
    _callAskingMessageId = null;
    _callStatus.value = CallStatus.calling;

    try {
      _joinCallChannel();
    } catch (e) {
      logger.e(e);
      _callStatus.value = CallStatus.none;
    }
  }

  void hangUp() {
    if (callStatusNotifier.value == CallStatus.none) return;
    _callStatus.value = CallStatus.none;
    AudioPlayer().play(AssetSource('sounds/hang_up.wav'));

    _agoraEngine.leaveChannel();
  }

  // range 0 ~ 400
  final volume = ValueNotifier<int>(100);
  final mute = ValueNotifier<bool>(false);
  void _loadSavedVolume() {
    final savedVolume = Preferences().get<int>('call_volume');
    if (savedVolume != null) volume.value = savedVolume;
  }

  void _setVolume(int volume) async {
    assert(volume >= 0 && volume <= 400);
    await _agoraEngine.adjustPlaybackSignalVolume(volume);
  }

  Future<void> _joinCallChannel() async {
    final channelData = await Chat().createVoiceCall();
    logger.i('try join voice channel: $channelData');

    const options = ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await _agoraEngine.joinChannel(
      token: channelData['token'],
      channelId: channelData['channelId'],
      uid: channelData['uid'],
      options: options,
    );
  }

  String? _callAskingMessageId;
  List<String>? _myCallAskingHopeList;
  late final _callAskingTimeOutTimer = RestartableTimer(
    const Duration(seconds: 30),
    () {
      showSnackBar('无人接听');
      cancelAsking();
    },
  )..cancel();

  void _myCallAskingHasBeenAccepted() {
    _callStatus.value = CallStatus.calling;
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
      cancelAsking();
    }
  }

  final _callRinger = AudioPlayer()..setSource(AssetSource('sounds/call.wav'));
}
